package common

import (
	"crypto/hmac"
	"crypto/md5"
	"crypto/sha1"
	"crypto/sha256"
	"encoding/hex"
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

func GenerateHMACWithKey(key []byte, data string) string {
	h := hmac.New(sha256.New, key)
	h.Write([]byte(data))
	return hex.EncodeToString(h.Sum(nil))
}

func GenerateHMAC(data string) string {
	h := hmac.New(sha256.New, []byte(CryptoSecret))
	h.Write([]byte(data))
	return hex.EncodeToString(h.Sum(nil))
}

func Password2Hash(password string) (string, error) {
	passwordBytes := []byte(password)
	hashedPassword, err := bcrypt.GenerateFromPassword(passwordBytes, bcrypt.DefaultCost)
	return string(hashedPassword), err
}

func ValidatePasswordAndHash(password string, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// CryptoPass 使用算力平台相同的密码加密方式 (MD5 + SHA1)
func CryptoPass(raw string) (string, error) {
	return SHA1(Md5Fn(raw))
}

// ValidateCryptoPass 验证密码是否匹配（用于算力平台集成）
// 参数: password 明文密码, hash 存储的哈希值
func ValidateCryptoPass(password string, hash string) bool {
	computedHash, err := CryptoPass(password)
	if err != nil {
		return false
	}
	return computedHash == hash
}

func SHA1(s string) (string, error) {
	o := sha1.New()
	o.Write([]byte(s))
	return hex.EncodeToString(o.Sum(nil)), nil

}
func Md5Fn(str string) string {
	data := []byte(str)
	// 默认是32位小写加密字符串
	return fmt.Sprintf("%x", md5.Sum(data))
}
