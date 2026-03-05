package limiter

import (
	"context"
	_ "embed"
	"fmt"
	"time"

	"github.com/QuantumNous/new-api/common"
	"github.com/go-redis/redis/v8"
)

const (
	slidingWindowFormat = "{%s}:sliding"
)

var (
	//go:embed lua/sliding_window_script.lua
	slidingWindowLuaScript string
	slidingWindowScript    *redis.Script

	//go:embed lua/sliding_window_get_script.lua
	slidingWindowGetLuaScript string
	slidingWindowGetScript    *redis.Script
)

// SlidingWindowLimiter implements rate limiting using sliding window algorithm with Redis
type SlidingWindowLimiter struct {
	rate   int           // 最大请求速率
	rpm    int           // 系统设置的RPM阈值
	window time.Duration // 窗口大小
	client *redis.Client
}

// NewSlidingWindowLimiter creates a new sliding window rate limiter
func NewSlidingWindowLimiter(client *redis.Client, rate int, rpm int, window ...time.Duration) *SlidingWindowLimiter {
	// 默认窗口大小为1分钟
	var windowDuration time.Duration = time.Minute
	if len(window) > 0 {
		windowDuration = window[0]
	}
	// Initialize scripts if not already done
	if slidingWindowScript == nil {
		slidingWindowScript = redis.NewScript(slidingWindowLuaScript)
	}
	if slidingWindowGetScript == nil {
		slidingWindowGetScript = redis.NewScript(slidingWindowGetLuaScript)
	}

	return &SlidingWindowLimiter{
		rate:   rate,
		rpm:    rpm,
		window: windowDuration,
		client: client,
	}
}

// Allow checks if a single request is allowed
func (l *SlidingWindowLimiter) Allow(keyPrefix string) bool {
	return l.AllowN(keyPrefix, 1)
}

// AllowN checks if n requests are allowed
func (l *SlidingWindowLimiter) AllowN(keyPrefix string, n int) bool {
	return l.reserveN(context.Background(), keyPrefix, n)
}

// GetCurrentRate returns the current rate for the given key
func (l *SlidingWindowLimiter) GetCurrentRate(keyPrefix string) (int, error) {
	if !common.RedisEnabled {
		return 0, fmt.Errorf("Redis未配置，API限速功能未生效，无法获取实时RPM")
	}
	slidingKey := fmt.Sprintf(slidingWindowFormat, keyPrefix)
	nowSec := time.Now().Unix()

	result, err := slidingWindowGetScript.Run(
		context.Background(),
		l.client,
		[]string{slidingKey},
		int(l.window.Seconds()), // ARGV[1]: 窗口大小（秒）
		nowSec,                  // ARGV[2]: 当前时间戳
	).Result()

	if err != nil {
		return 0, err
	}

	// 如果是redis.Nil错误，表示计数不存在，已用速率为0
	if result == nil {
		return 0, nil
	}

	count, ok := result.(int64)
	if !ok {
		return 0, fmt.Errorf("无法转换计数结果")
	}

	return int(count), nil
}

// reserveN 预留N个请求位置
func (l *SlidingWindowLimiter) reserveN(ctx context.Context, keyPrefix string, n int) bool {
	slidingKey := fmt.Sprintf(slidingWindowFormat, keyPrefix)
	nowSec := time.Now().Unix()

	result, err := slidingWindowScript.Run(
		ctx,
		l.client,
		[]string{slidingKey},
		l.rate,                  // ARGV[1]: 最大速率限制
		int(l.window.Seconds()), // ARGV[2]: 窗口大小（秒）
		nowSec,                  // ARGV[3]: 当前时间戳
		n,                       // ARGV[4]: 增加的请求数
	).Result()

	if err != nil {
		return false
	}

	resultArray, ok := result.([]interface{})
	if !ok || len(resultArray) < 1 {
		return false
	}

	allowed, ok := resultArray[0].(int64)
	if !ok {
		return false
	}

	return allowed == 1
}
