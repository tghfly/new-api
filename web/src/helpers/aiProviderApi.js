/*
Copyright (C) 2025 QuantumNous

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

For commercial licensing, please contact support@quantumnous.com
*/

import axios from 'axios';
import Cookies from 'js-cookie';

// 创建独立的 axios 实例用于 AI Provider 服务
export const AIProviderAPI = axios.create({
  baseURL: 'https://dcloud.tydic.com:28443/ai-provider',
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器 - 从 Cookie 中获取 token 并添加 Authorization header
AIProviderAPI.interceptors.request.use(
  (config) => {
    // 尝试获取 dcloud_token 或 token
    let token = Cookies.get('dcloud_token');
    if (!token) {
      token = Cookies.get('token');
    }
    
    console.log('AI Provider API - Token from cookie:', token ? 'found' : 'not found');
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// 响应拦截器 - 错误处理
AIProviderAPI.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('AI Provider API Error:', error);
    return Promise.reject(error);
  }
);

/**
 * 获取推理服务模型信息
 * @param {string|number} id - 推理服务ID
 * @returns {Promise<Object>}
 */
export async function fetchInferenceService(id) {
  const response = await AIProviderAPI.get(`/inferenceservice_modelview/api/${id}`);
  return response.data;
}

/**
 * 获取模型注册信息
 * @param {string|number} id - 模型注册ID
 * @returns {Promise<Object>}
 */
export async function fetchModelRegistry(id) {
  const response = await AIProviderAPI.get(`/training_model_modelview/api/${id}`);
  return response.data;
}
