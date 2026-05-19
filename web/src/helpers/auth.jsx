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

import React, { useEffect, useState, useCallback, useContext } from 'react';
import { Navigate } from 'react-router-dom';
import { history } from './history';
import { API } from './api';
import { setUserData } from './data';
import { UserContext } from '../context/User';

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

      // DCloud 登录后同步项目信息
      await syncDCloudProjects();

      return true;
    }
  } catch (error) {
    // Session 无效或请求失败
    console.debug('Session check failed:', error?.message);
  }
  return false;
}

// syncDCloudProjects 从 localStorage 读取算力平台项目信息并同步到后端
async function syncDCloudProjects() {
  try {
    // 读取算力平台用户信息
    const userInfoStr = localStorage.getItem('saber-userInfo');
    const currentProjectStr = localStorage.getItem('saber-currentProject');

    if (!userInfoStr) {
      return;
    }

    let userInfo;
    try {
      userInfo = JSON.parse(userInfoStr);
    } catch (e) {
      return;
    }

    const content = userInfo?.content;
    if (!content) {
      return;
    }

    // 解析项目列表
    const projectIds = content.projectId?.split(',') || [];
    const projectCodes = content.project_code?.split(',') || content.projectCode?.split(',') || [];
    const projectNames = content.projectName?.split(',') || [];

    if (projectIds.length === 0 || projectCodes.length === 0) {
      return;
    }

    // 构建项目列表
    const filteredProjects = projectIds.map((id, index) => ({
      external_id: parseInt(id, 10),
      project_code: projectCodes[index] || '',
      project_name: projectNames[index] || projectCodes[index] || '',
    })).filter(p => p.project_code);

    if (filteredProjects.length === 0) {
      return;
    }

    // 解析当前项目
    let currentProjectCode = '';
    if (currentProjectStr) {
      try {
        const currentProject = JSON.parse(currentProjectStr);
        currentProjectCode = currentProject?.content?.project_code || '';
      } catch (e) {
        // ignore
      }
    }

    // 如果没有当前项目，使用第一个
    if (!currentProjectCode && filteredProjects.length > 0) {
      currentProjectCode = filteredProjects[0].project_code;
    }

    // 调用后端同步接口
    try {
      await API.post('/api/user-groups/sync', {
        tenant_id: content.tenantId || '',
        vdc_code: content.vdcCode || '',
        projects: filteredProjects,
        current_project_code: currentProjectCode,
      }, { skipErrorHandler: true });
    } catch (error) {
      console.error('Sync DCloud projects failed:', error?.message);
    }
  } catch (error) {
    console.debug('Sync DCloud projects failed:', error?.message);
  }
}

function PrivateRoute({ children }) {
  const [checking, setChecking] = useState(true);
  const [authenticated, setAuthenticated] = useState(false);
  const [, userDispatch] = useContext(UserContext);

  const checkAuth = useCallback(async () => {
    const userStr = localStorage.getItem('user');
    if (userStr) {
      // 已有 localStorage 数据，同步到 UserContext
      try {
        const user = JSON.parse(userStr);
        userDispatch({ type: 'login', payload: user });
      } catch (e) {
        // ignore parse error
      }
      setAuthenticated(true);
      setChecking(false);
      // 即使有 user 信息，也尝试同步项目信息（处理从算力平台跳转的情况）
      syncDCloudProjects();
      return;
    }

    // 检查后端 Session 状态（DCloud SSO 场景）
    const sessionValid = await checkSessionStatus();
    if (sessionValid) {
      // checkSessionStatus 已写入 localStorage，现在同步到 UserContext
      const newUserStr = localStorage.getItem('user');
      if (newUserStr) {
        try {
          const user = JSON.parse(newUserStr);
          userDispatch({ type: 'login', payload: user });
        } catch (e) {
          // ignore parse error
        }
      }
      setAuthenticated(true);
    }
    setChecking(false);
  }, [userDispatch]);

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
  const [, userDispatch] = useContext(UserContext);

  const checkAuth = useCallback(async () => {
    const raw = localStorage.getItem('user');
    if (raw) {
      try {
        const user = JSON.parse(raw);
        if (user && typeof user.role === 'number' && user.role >= 10) {
          // 同步到 UserContext
          userDispatch({ type: 'login', payload: user });
          setAuthorized(true);
          setChecking(false);
          // 尝试同步项目信息
          syncDCloudProjects();
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
            // 同步到 UserContext
            userDispatch({ type: 'login', payload: user });
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
  }, [userDispatch]);

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
