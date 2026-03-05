package limiter

import (
	"context"
	_ "embed"
	"errors"
	"fmt"
	"strconv"
	"time"

	"github.com/QuantumNous/new-api/common"
	"github.com/go-redis/redis/v8"
)

const (
	tokenFormat      = "{%s}:tokens"
	timestampFormat  = "{%s}:ts"
	counterFormat    = "{%s}:counter" // 请求计数器key
	lastMinuteFormat = "{%s}:lastmin" // 上一分钟时间戳key
)

var (
	//go:embed lua/token_script.lua
	tokenLuaScript string
	tokenScript    *redis.Script

	//go:embed lua/token_get_script.lua
	tokenGetLuaScript string
	tokenGetScript    *redis.Script
)

// TokenLimiter implements rate limiting using token bucket algorithm with Redis
type TokenLimiter struct {
	rate   int // 每秒的速率阈值
	rpm    int // rpm阈值
	burst  int
	client *redis.Client
}

// NewTokenLimiter returns a new TokenLimiter that allows events up to rate and permits
// bursts of at most burst tokens.
func NewTokenLimiter(client *redis.Client, rate, rpm, burst int) *TokenLimiter {
	// Initialize scripts if not already done
	if tokenScript == nil {
		tokenScript = redis.NewScript(tokenLuaScript)
	}
	if tokenGetScript == nil {
		tokenGetScript = redis.NewScript(tokenGetLuaScript)
	}

	return &TokenLimiter{
		rate:   rate,
		rpm:    rpm,
		burst:  burst,
		client: client,
	}
}

func (lim *TokenLimiter) Allow(keyPrefix string) bool {
	return lim.AllowN(keyPrefix, 1)
}

// AllowN reports whether n events may happen at time now.
func (lim *TokenLimiter) AllowN(keyPrefix string, n int) bool {
	return lim.reserveN(context.Background(), keyPrefix, n)
}

// GetCurrentRate 获取当前速率使用情况，返回已使用的速率
func (lim *TokenLimiter) GetCurrentRate(keyPrefix string) (int, error) {
	if !common.RedisEnabled {
		return 0, fmt.Errorf("Redis未配置，API限速功能未生效，无法获取实时RPM")
	}
	tokenKey := fmt.Sprintf(tokenFormat, keyPrefix)
	timestampKey := fmt.Sprintf(timestampFormat, keyPrefix)
	counterKey := fmt.Sprintf(counterFormat, keyPrefix)
	lastMinuteKey := fmt.Sprintf(lastMinuteFormat, keyPrefix)

	resp, err := tokenGetScript.Run(context.Background(), lim.client, []string{
		tokenKey,
		timestampKey,
		counterKey,
		lastMinuteKey,
	},
		strconv.Itoa(lim.rate),
		strconv.Itoa(lim.burst),
		strconv.FormatInt(time.Now().Unix(), 10),
		strconv.Itoa(lim.rpm),
	).Result()

	if errors.Is(err, redis.Nil) {
		return 0, nil
	}
	if err != nil {
		common.SysError(fmt.Sprintf("fail to get current rate: %s", err))
		return 0, err
	}

	// 如果没有使用过令牌，则返回0
	if resp == nil {
		return 0, nil
	}

	// 尝试转换为接口数组
	result, ok := resp.([]interface{})
	if !ok || len(result) < 3 {
		common.SysError(fmt.Sprintf("fail to convert token result: %v", resp))
		return 0, fmt.Errorf("无法转换令牌使用结果")
	}

	// 获取实时RPM（索引1是当前RPM）
	var realTimeRPM int
	switch v := result[1].(type) {
	case int64:
		realTimeRPM = int(v)
	case int:
		realTimeRPM = v
	default:
		common.SysError(fmt.Sprintf("unexpected type for RPM result: %T", result[1]))
		return 0, fmt.Errorf("无法转换RPM结果: %v", result[1])
	}

	// 返回实时RPM
	if lim.rpm == 0 {
		return 0, nil
	}
	return realTimeRPM, nil
}

func (lim *TokenLimiter) reserveN(ctx context.Context, keyPrefix string, n int) bool {
	tokenKey := fmt.Sprintf(tokenFormat, keyPrefix)
	timestampKey := fmt.Sprintf(timestampFormat, keyPrefix)
	counterKey := fmt.Sprintf(counterFormat, keyPrefix)
	lastMinuteKey := fmt.Sprintf(lastMinuteFormat, keyPrefix)

	resp, err := tokenScript.Run(ctx, lim.client, []string{
		tokenKey,
		timestampKey,
		counterKey,
		lastMinuteKey,
	},
		strconv.Itoa(lim.rate),
		strconv.Itoa(lim.burst),
		strconv.FormatInt(time.Now().Unix(), 10),
		strconv.Itoa(n),
		strconv.Itoa(lim.rpm),
	).Result()

	// redis allowed == false
	// Lua boolean false -> r Nil bulk reply
	if errors.Is(err, redis.Nil) {
		return false
	}
	if errors.Is(err, context.DeadlineExceeded) || errors.Is(err, context.Canceled) {
		common.SysError(fmt.Sprintf("fail to use rate limiter: %s", err))
		return false
	}
	if err != nil {
		common.SysError(fmt.Sprintf("fail to use rate limiter: %s, use in-process limiter for rescue", err))
		return false
	}

	// Lua脚本返回的是布尔值，在Redis中布尔true会转为1，false会返回nil
	switch v := resp.(type) {
	case int64:
		return v == 1
	case bool:
		return v
	default:
		common.SysError(fmt.Sprintf("unexpected return type from redis script: %T %v, use in-process limiter for rescue", resp, resp))
		return false
	}
}
