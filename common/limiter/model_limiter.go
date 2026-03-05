package limiter

import (
	"context"
	"time"

	"github.com/go-redis/redis/v8"
)

// Option 定义限流器选项函数
type Option func(*ModelLimiterConfig)

// ModelLimiterConfig 模型限流器配置
type ModelLimiterConfig struct {
	Capacity  int64
	Rate      int64
	Requested int64
}

// ModelLimiter 模型限流器
type ModelLimiter struct {
	ctx    context.Context
	client *redis.Client
	config ModelLimiterConfig
}

// WithCapacity 设置容量
func WithCapacity(capacity int64) Option {
	return func(c *ModelLimiterConfig) {
		c.Capacity = capacity
	}
}

// WithRate 设置速率
func WithRate(rate int64) Option {
	return func(c *ModelLimiterConfig) {
		c.Rate = rate
	}
}

// WithRequested 设置请求数
func WithRequested(requested int64) Option {
	return func(c *ModelLimiterConfig) {
		c.Requested = requested
	}
}

// New 创建新的模型限流器
func New(ctx context.Context, client *redis.Client) *ModelLimiter {
	return &ModelLimiter{
		ctx:    ctx,
		client: client,
		config: ModelLimiterConfig{},
	}
}

// Allow 检查是否允许请求
func (m *ModelLimiter) Allow(ctx context.Context, key string, opts ...Option) (bool, error) {
	// 应用选项
	for _, opt := range opts {
		opt(&m.config)
	}

	// 计算窗口大小（秒）
	windowSeconds := m.config.Requested
	if windowSeconds <= 0 {
		windowSeconds = 60 // 默认60秒
	}

	// 使用滑动窗口限流器进行限流
	limiter := NewSlidingWindowLimiter(m.client, int(m.config.Rate), int(m.config.Rate), time.Duration(windowSeconds)*time.Second)
	return limiter.Allow(key), nil
}
