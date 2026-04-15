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

export function setStatusData(data) {
  localStorage.setItem('status', JSON.stringify(data));
  localStorage.setItem('system_name', data.system_name);
  localStorage.setItem('logo', data.logo);
  localStorage.setItem('footer_html', data.footer_html);
  localStorage.setItem('quota_per_unit', data.quota_per_unit);
  // 兼容：保留旧字段，同时写入新的额度展示类型
  localStorage.setItem('display_in_currency', data.display_in_currency);
  localStorage.setItem('quota_display_type', data.quota_display_type || 'USD');
  localStorage.setItem('enable_drawing', data.enable_drawing);
  localStorage.setItem('enable_task', data.enable_task);
  localStorage.setItem('enable_data_export', data.enable_data_export);
  localStorage.setItem('chats', JSON.stringify(data.chats));
  localStorage.setItem(
    'data_export_default_time',
    data.data_export_default_time,
  );
  localStorage.setItem(
    'default_collapse_sidebar',
    data.default_collapse_sidebar,
  );
  localStorage.setItem('mj_notify_enabled', data.mj_notify_enabled);
  if (data.chat_link) {
    // localStorage.setItem('chat_link', data.chat_link);
  } else {
    localStorage.removeItem('chat_link');
  }
  if (data.chat_link2) {
    // localStorage.setItem('chat_link2', data.chat_link2);
  } else {
    localStorage.removeItem('chat_link2');
  }
  if (data.docs_link) {
    localStorage.setItem('docs_link', data.docs_link);
  } else {
    localStorage.removeItem('docs_link');
  }
}

export function setUserData(data) {
  const ssoPerms = getSSOPerms();
  if (ssoPerms && ssoPerms.length > 0) {
    // 根据 SSO 权限计算用户角色
    let role;
    if (ssoPerms.includes('m:ai-web:modelstation:setting')) {
      role = 100;
    } else if (
      ssoPerms.includes('m:ai-web:modelstation:user') ||
      ssoPerms.includes('m:ai-web:modelstation:usergroup') ||
      ssoPerms.includes('m:ai-web:modelstation:channel')
    ) {
      role = 10;
    } else {
      role = data.role;
    }
    data.role = role;
  }
  localStorage.setItem('user', JSON.stringify(data));
}

// ssoPerms 格式: ['m:ai-web:modelstation:user', 'm:ai-web:modelstation:usergroup', 'm:ai-web:modelstation:setting']
export function getSSOPerms() {
  const ssoPermsStr = localStorage.getItem('saber-sso-perms');
  const parsed = ssoPermsStr ? JSON.parse(ssoPermsStr) : null;
  return parsed?.content || [];
}

// 判断是否拥有指定 SSO 权限
// hasSSOPerm('b:ai-web:modelstation:dashboard:recharge')
// 当 ssoPerms 为空时（长度=0），返回 true（兼容非SSO场景）
export function hasSSOPerm(ssoKey) {
  const ssoPerms = getSSOPerms();
  if (ssoPerms.length === 0) {
    return true;
  }
  return ssoPerms.includes(ssoKey);
}
