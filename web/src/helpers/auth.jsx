/*
Copyright (C) 2025 QuantumNous

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

For commercial commercial, please contact support@quantumnous.com
*/

import React, { useEffect, useState, useCallback } from 'react';
import { Navigate } from 'react-router-dom';
import { history } from './history';
import { API } from './api';
import { setUserData } from './data';

export function authHeader() {
  // return authorization header with jwt token
  let user = JSON.parse(localStorage.getItem('user'));

  if (user && user.token) {
    return { Authorization: 'Bearer ' + user.token };
  } else {
    return {};
  }
}

export const AuthRedirect = ({ children }) => {
  const user = localStorage.getItem('user');

  if (user) {
    return <Navigate to='/console' replace />;
  }

  return children;
};

// 检查后端 Session 状态（用于 DCloud SSO 等场景）
export async function checkSessionStatus() {
  try {
    const res = await API.get('/api/user/self', { skipErrorHandler: true });
    const { success, data } = res.data;
    if (success && data) {
      setUserData(data);
      return true;
    }
  } catch (error) {
    // Session 无效或请求失败
    console.debug('Session check failed:', error?.message);
  }
  return false;
}

function PrivateRoute({ children }) {
  const [checking, setChecking] = useState(true);
  const [authenticated, setAuthenticated] = useState(false);

  const checkAuth = useCallback(async () => {
    const user = localStorage.getItem('user');
    if (user) {
      setAuthenticated(true);
      setChecking(false);
      return;
    }

    // 检查后端 Session 状态（DCloud SSO 场景）
    const sessionValid = await checkSessionStatus();
    if (sessionValid) {
      setAuthenticated(true);
    }
    setChecking(false);
  }, []);

  useEffect(() => {
    checkAuth();
  }, [checkAuth]);

  if (checking) {
    // 返回 null 或 loading 状态，避免闪烁
    return null;
  }

  if (!authenticated) {
    return <Navigate to='/login' state={{ from: history.location }} />;
  }

  return children;
}

export function AdminRoute({ children }) {
  const [checking, setChecking] = useState(true);
  const [authorized, setAuthorized] = useState(false);

  const checkAuth = useCallback(async () => {
    const raw = localStorage.getItem('user');
    if (raw) {
      try {
        const user = JSON.parse(raw);
        if (user && typeof user.role === 'number' && user.role >= 10) {
          setAuthorized(true);
          setChecking(false);
          return;
        }
      } catch (e) {
        // ignore
      }
    }

    // 检查后端 Session 状态（DCloud SSO 场景）
    const sessionValid = await checkSessionStatus();
    if (sessionValid) {
      const newRaw = localStorage.getItem('user');
      if (newRaw) {
        try {
          const user = JSON.parse(newRaw);
          if (user && typeof user.role === 'number' && user.role >= 10) {
            setAuthorized(true);
            setChecking(false);
            return;
          }
        } catch (e) {
          // ignore
        }
      }
    }
    setChecking(false);
  }, []);

  useEffect(() => {
    checkAuth();
  }, [checkAuth]);

  if (checking) {
    return null;
  }

  if (!authorized) {
    // 如果有用户信息但权限不足，跳转到 forbidden
    const raw = localStorage.getItem('user');
    if (raw) {
      return <Navigate to='/forbidden' replace />;
    }
    return <Navigate to='/login' state={{ from: history.location }} />;
  }

  return children;
}

export { PrivateRoute };
