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

import React, { useMemo, useState } from 'react';
import { Typography, Button, Toast, Tooltip, Tag } from '@douyinfe/semi-ui';
import { IconKey, IconCopy, IconTick } from '@douyinfe/semi-icons';
import CompactModeToggle from '../../common/ui/CompactModeToggle';
import { copy } from '../../../helpers/utils';

const { Text } = Typography;

const TokensDescription = ({ compactMode, setCompactMode, setShowExample, setExampleBaseUrl, t }) => {
  const [copied, setCopied] = useState(false);

  // 获取基础URL
  const baseUrl = useMemo(() => {
    // 优先使用当前浏览器地址
    let serverAddress = window.location.origin;

    // 尝试从 localStorage 读取（仅作为备选，且需要验证合理性）
    const status = localStorage.getItem('status');
    if (status) {
      try {
        const statusObj = JSON.parse(status);
        const storedAddress = statusObj.server_address;
        // 如果存储的地址与当前域名一致，才考虑使用
        if (storedAddress) {
          const currentHost = window.location.host;
          const storedUrl = new URL(storedAddress);
          if (storedUrl.host === currentHost) {
            serverAddress = storedAddress;
          }
        }
      } catch (_) {
        // 解析失败，忽略
      }
    }

    return `${serverAddress}/v1`;
  }, []);

  // 复制基础URL到剪贴板
  const handleCopyBaseUrl = async () => {
    try {
      await copy(baseUrl);
      setCopied(true);
      Toast.success(t('已复制到剪贴板'));
      setTimeout(() => setCopied(false), 2000);
    } catch (e) {
      Toast.error(t('复制失败'));
    }
  };

  return (
    <div className='flex flex-col md:flex-row justify-between items-start md:items-center gap-3 w-full'>
      {/* 左侧：标题 + API URL */}
      <div className='flex flex-col sm:flex-row items-start sm:items-center gap-2 sm:gap-4'>
        {/* 标题 */}
        <div className='flex items-center text-blue-500 shrink-0'>
          <IconKey size={16} className='mr-2' />
          <Text strong>{t('令牌管理')}</Text>
        </div>

        {/* 分隔线 */}
        <div className='hidden sm:block w-px h-4 bg-gray-300' />

        {/* API 基础 URL - 精致的标签样式 */}
        <div className='flex items-center gap-2'>
          <Text type='secondary' size='small' className='whitespace-nowrap shrink-0'>
            {t('API 基础 URL')}
          </Text>
          <Tooltip content={baseUrl} position='bottom'>
            <Tag
              size='small'
              className='font-mono text-blue-600 bg-blue-50 border-blue-200 cursor-pointer hover:bg-blue-100 transition-colors max-w-[200px] sm:max-w-[280px] md:max-w-[350px] truncate'
              onClick={handleCopyBaseUrl}
            >
              <span className='truncate block'>{baseUrl}</span>
            </Tag>
          </Tooltip>
          <Tooltip content={copied ? t('已复制') : t('复制')}>
            <Button
              theme='light'
              type='tertiary'
              size='small'
              icon={copied ? <IconTick style={{ color: 'var(--semi-color-success)' }} /> : <IconCopy />}
              onClick={handleCopyBaseUrl}
              className='shrink-0'
            />
          </Tooltip>
          <Button
            theme='light'
            type='tertiary'
            size='small'
            onClick={() => {
              setShowExample(true);
              setExampleBaseUrl && setExampleBaseUrl(baseUrl);
            }}
            className='shrink-0'
          >
            {t('示例')}
          </Button>
        </div>
      </div>

      {/* 右侧：紧凑模式切换 */}
      <CompactModeToggle
        compactMode={compactMode}
        setCompactMode={setCompactMode}
        t={t}
      />
    </div>
  );
};

export default TokensDescription;
