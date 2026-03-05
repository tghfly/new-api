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

import React, { createContext, useContext, useEffect, useReducer, useCallback } from 'react';
import { API } from '../../helpers';
import { initialState, reducer, actionTypes } from './reducer';
import { UserContext } from '../User';

const UserGroupContext = createContext();

export const useUserGroupContext = () => {
  const context = useContext(UserGroupContext);
  if (!context) {
    throw new Error('useUserGroupContext must be used within UserGroupProvider');
  }
  return context;
};

export const UserGroupProvider = ({ children }) => {
  const [state, dispatch] = useReducer(reducer, initialState);
  const [userState] = useContext(UserContext);
  const user = userState?.user;

  const loadGroupMap = useCallback(async () => {
    dispatch({ type: actionTypes.SET_LOADING, payload: true });
    try {
      let response;
      // 管理员: role >= 10 (RoleAdminUser=10, RoleRootUser=100)
      const isAdmin = Number(user?.role) >= 10;
      if (isAdmin) {
        response = await API.get('/api/admin/user_groups/all');
      } else {
        response = await API.get('/api/user/self/groups');
      }

      if (response.data.success) {
        let groupMap = {};
        // 合并现有数据
        const existingStr = localStorage.getItem('user_group_names');
        const existing = existingStr ? JSON.parse(existingStr) : {};
        groupMap = { ...existing };
        
        if (Array.isArray(response.data.data)) {
          // 数组格式：[{ symbol: "xxx", name: "yyy" }]
          response.data.data.forEach(item => {
            if (item.symbol && item.name) {
              groupMap[item.symbol] = item.name;
            }
          });
        } else if (typeof response.data.data === 'object' && response.data.data !== null) {
          // 对象格式：{ "symbol": "name" }
          groupMap = response.data.data;
        }
        
        // 保存到 localStorage
        localStorage.setItem('user_group_names', JSON.stringify(groupMap));
        dispatch({ type: actionTypes.SET_GROUP_MAP, payload: groupMap });
      }
    } catch (error) {
      // 尝试从 localStorage 加载
      try {
        const stored = localStorage.getItem('user_group_names');
        if (stored) {
          const groupMap = JSON.parse(stored);
          dispatch({ type: actionTypes.SET_GROUP_MAP, payload: groupMap });
        }
      } catch (e) {
        dispatch({ type: actionTypes.SET_ERROR, payload: error.message });
      }
    }
  }, [user]);

  // 初始化时从 localStorage 加载
  useEffect(() => {
    try {
      const stored = localStorage.getItem('user_group_names');
      if (stored) {
        const groupMap = JSON.parse(stored);
        dispatch({ type: actionTypes.SET_GROUP_MAP, payload: groupMap });
      }
    } catch (e) {
      // ignore
    }
  }, []);

  // 用户变化时重新加载
  useEffect(() => {
    if (user && user.id) {
      loadGroupMap();
    }
  }, [user, loadGroupMap]);

  const updateGroupMap = (newGroupMap) => {
    dispatch({ type: actionTypes.UPDATE_GROUP_MAP, payload: newGroupMap });
    // 更新 localStorage
    const currentMap = { ...state.groupMap, ...newGroupMap };
    localStorage.setItem('user_group_names', JSON.stringify(currentMap));
  };

  const value = {
    ...state,
    loadGroupMap,
    updateGroupMap,
  };

  return (
    <UserGroupContext.Provider value={value}>
      {children}
    </UserGroupContext.Provider>
  );
};