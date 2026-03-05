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
	countFormat = "{%s}:count"
)

var (
	//go:embed lua/count_script.lua
	countLuaScript string
	countScript    *redis.Script

	//go:embed lua/count_get_script.lua
	countGetLuaScript string
	countGetScript    *redis.Script
)

// CountLimiter implements rate limiting using fixed window algorithm with Redis
type CountLimiter struct {
	rate   int
	rpm    int
	window time.Duration
	client *redis.Client
}

// NewCountLimiter creates a new count-based rate limiter
func NewCountLimiter(client *redis.Client, rate int, rpm int, window time.Duration) *CountLimiter {
	// Initialize scripts if not already done
	if countScript == nil {
		countScript = redis.NewScript(countLuaScript)
	}
	if countGetScript == nil {
		countGetScript = redis.NewScript(countGetLuaScript)
	}

	return &CountLimiter{
		rate:   rate,
		rpm:    rpm,
		window: window,
		client: client,
	}
}

// Allow checks if a single request is allowed
func (l *CountLimiter) Allow(keyPrefix string) bool {
	return l.AllowN(keyPrefix, 1)
}

// AllowN checks if n requests are allowed
func (l *CountLimiter) AllowN(keyPrefix string, n int) bool {
	return l.reserveN(context.Background(), keyPrefix, n)
}

// GetCurrentRate returns the current rate for the given key
func (l *CountLimiter) GetCurrentRate(keyPrefix string) (int, error) {
	if !common.RedisEnabled {
		return 0, fmt.Errorf("Redis未配置，API限速功能未生效，无法获取实时RPM")
	}
	countKey := fmt.Sprintf(countFormat, keyPrefix)
	result, err := countGetScript.Run(context.Background(), l.client, []string{
		countKey,
	}).Result()

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

	// count是当前已经使用的请求数量
	return int(count), nil
}

func (l *CountLimiter) reserveN(ctx context.Context, keyPrefix string, n int) bool {
	countKey := fmt.Sprintf(countFormat, keyPrefix)

	result, err := countScript.Run(ctx, l.client, []string{
		countKey,
	},
		l.rate,                  // ARGV[1]: rate
		int(l.window.Seconds()), // ARGV[2]: window size in seconds
		n,
	).Result()

	if err != nil {
		return false
	}

	return result.(int64) == 1
}
