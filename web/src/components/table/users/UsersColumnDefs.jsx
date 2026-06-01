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

import React from 'react';
import {
  Button,
  Space,
  Tag,
  Tooltip,
  Progress,
  Popover,
  Typography,
  Dropdown,
} from '@douyinfe/semi-ui';
import { IconMore } from '@douyinfe/semi-icons';
import { renderGroup, renderNumber, renderQuota, hasSSOPerm } from '../../../helpers';

/**
 * Render username with remark
 */
const renderUsername = (text, record) => {
  const remark = record.remark;
  if (!remark) {
    return <span>{text}</span>;
  }
  const maxLen = 10;
  const displayRemark =
    remark.length > maxLen ? remark.slice(0, maxLen) + '…' : remark;
  return (
    <Space spacing={2}>
      <span>{text}</span>
      <Tooltip content={remark} position='top' showArrow>
        <Tag color='white' shape='circle' className='!text-xs'>
          <div className='flex items-center gap-1'>
            <div
              className='w-2 h-2 flex-shrink-0 rounded-full'
              style={{ backgroundColor: '#10b981' }}
            />
            {displayRemark}
          </div>
        </Tag>
      </Tooltip>
    </Space>
  );
};

/**
 * Render user statistics
 */
const renderStatistics = (text, record, showEnableDisableModal, t) => {
  const isDeleted = record.DeletedAt !== null;

  // Determine tag text & color like original status column
  let tagColor = 'grey';
  let tagText = t('未知状态');
  if (isDeleted) {
    tagColor = 'red';
    tagText = t('已注销');
  } else if (record.status === 1) {
    tagColor = 'green';
    tagText = t('已启用');
  } else if (record.status === 2) {
    tagColor = 'red';
    tagText = t('已禁用');
  }

  const content = (
    <Tag color={tagColor} shape='circle' size='small'>
      {tagText}
    </Tag>
  );

  const tooltipContent = (
    <div className='text-xs'>
      <div>
        {t('调用次数')}: {renderNumber(record.request_count)}
      </div>
    </div>
  );

  return (
    <Tooltip content={tooltipContent} position='top'>
      {content}
    </Tooltip>
  );
};

// Render separate quota usage column
const renderQuotaUsage = (text, record, t) => {
  const { Paragraph } = Typography;
  const used = parseInt(record.used_quota) || 0;
  const remain = parseInt(record.quota) || 0;
  const total = used + remain;
  const percent = total > 0 ? (remain / total) * 100 : 0;
  const popoverContent = (
    <div className='text-xs p-2'>
      <Paragraph copyable={{ content: renderQuota(used) }}>
        {t('已用额度')}: {renderQuota(used)}
      </Paragraph>
      <Paragraph copyable={{ content: renderQuota(remain) }}>
        {t('剩余额度')}: {renderQuota(remain)} ({percent.toFixed(0)}%)
      </Paragraph>
      <Paragraph copyable={{ content: renderQuota(total) }}>
        {t('总额度')}: {renderQuota(total)}
      </Paragraph>
    </div>
  );
  return (
    <Popover content={popoverContent} position='top'>
      <Tag color='white' shape='circle'>
        <div className='flex flex-col items-end'>
          <span className='text-xs leading-none'>{`${renderQuota(remain)} / ${renderQuota(total)}`}</span>
          <Progress
            percent={percent}
            aria-label='quota usage'
            format={() => `${percent.toFixed(0)}%`}
            style={{ width: '100%', marginTop: '1px', marginBottom: 0 }}
          />
        </div>
      </Tag>
    </Popover>
  );
};

/**
 * Render operations column
 */
const renderOperations = (
  text,
  record,
  {
    setEditingUser,
    setShowEditUser,
    showPromoteModal,
    showDemoteModal,
    showEnableDisableModal,
    showDeleteModal,
    showResetPasskeyModal,
    showResetTwoFAModal,
    showUserSubscriptionsModal,
    t,
  },
) => {
  if (record.DeletedAt !== null) {
    return <></>;
  }

  const moreMenu = [];

  // 订阅管理
  if (hasSSOPerm('b:ai-web:modelstation:user:subscription')) {
    moreMenu.push({
      node: 'item',
      name: t('订阅管理'),
      onClick: () => showUserSubscriptionsModal(record),
    });
    moreMenu.push({ node: 'divider' });
  }
  // 提升
  if (hasSSOPerm('b:ai-web:modelstation:user:promote')) {
    moreMenu.push({
      node: 'item',
      name: t('提升'),
      onClick: () => showPromoteModal(record),
    });
  }

  // 降级
  if (hasSSOPerm('b:ai-web:modelstation:user:demote')) {
    moreMenu.push({
      node: 'item',
      name: t('降级'),
      onClick: () => showDemoteModal(record),
    });
  }

  // 重置 Passkey
  if (hasSSOPerm('b:ai-web:modelstation:user:resetpasskey')) {
    moreMenu.push({
      node: 'item',
      name: t('重置 Passkey'),
      onClick: () => showResetPasskeyModal(record),
    });
  }

  // 重置 2FA
  if (hasSSOPerm('b:ai-web:modelstation:user:reset2fa')) {
    moreMenu.push({
      node: 'item',
      name: t('重置 2FA'),
      onClick: () => showResetTwoFAModal(record),
    });
  }

  // 注销
  if (hasSSOPerm('b:ai-web:modelstation:user:delete')) {
    moreMenu.push({ node: 'divider' });
    moreMenu.push({
      node: 'item',
      name: t('注销'),
      type: 'danger',
      onClick: () => showDeleteModal(record),
    });
  }

  return (
    <Space>
      {(hasSSOPerm('b:ai-web:modelstation:user:enable') ||
        hasSSOPerm('b:ai-web:modelstation:user:disable')) && (
        <>
          {record.status === 1
            ? hasSSOPerm('b:ai-web:modelstation:user:disable') && (
                <Button
                  type='danger'
                  size='small'
                  onClick={() => showEnableDisableModal(record, 'disable')}
                >
                  {t('禁用')}
                </Button>
              )
            : hasSSOPerm('b:ai-web:modelstation:user:enable') && (
                <Button
                  size='small'
                  onClick={() => showEnableDisableModal(record, 'enable')}
                >
                  {t('启用')}
                </Button>
              )}
        </>
      )}

      {hasSSOPerm('b:ai-web:modelstation:user:edit') && (
        <Button
          type='tertiary'
          size='small'
          onClick={() => {
            setEditingUser(record);
            setShowEditUser(true);
          }}
        >
          {t('编辑')}
        </Button>
      )}

      {moreMenu.length > 0 && (
        <Dropdown menu={moreMenu} trigger='click' position='bottomRight'>
          <Button type='tertiary' size='small' icon={<IconMore />} />
        </Dropdown>
      )}
    </Space>
  );
};

/**
 * Get users table column definitions
 */
export const getUsersColumns = ({
  t,
  setEditingUser,
  setShowEditUser,
  showPromoteModal,
  showDemoteModal,
  showEnableDisableModal,
  showDeleteModal,
  showResetPasskeyModal,
  showResetTwoFAModal,
  showUserSubscriptionsModal,
}) => {
  return [
    {
      title: 'ID',
      dataIndex: 'id',
    },
    {
      title: t('用户名'),
      dataIndex: 'username',
      render: (text, record) => renderUsername(text, record),
    },
    {
      title: t('状态'),
      dataIndex: 'info',
      render: (text, record, index) =>
        renderStatistics(text, record, showEnableDisableModal, t),
    },
    {
      title: t('剩余额度/总额度(Token)'),
      key: 'quota_usage',
      render: (text, record) => renderQuotaUsage(text, record, t),
    },
    {
      title: t('项目'),
      dataIndex: 'group',
      render: (text, record, index) => {
        return <div>{renderGroup(text)}</div>;
      },
    },
    {
      title: t('限速配置'),
      dataIndex: 'rate_limit',
      render: (text, record, index) => {
        const hasUserLimit = record.api_rate_total > 0 || record.api_rate_success > 0;
        if (!hasUserLimit) {
          return (
            <Tag color='grey' shape='circle' size='small'>
              {t('使用组配置')}
            </Tag>
          );
        }
        return (
          <Tooltip
            content={
              <div className='text-xs'>
                <div>{t('总请求')}: {record.api_rate_total || t('无限制')}</div>
                <div>{t('成功请求')}: {record.api_rate_success || t('无限制')}</div>
              </div>
            }
            position='top'
          >
            <Tag color='blue' shape='circle' size='small'>
              {t('自定义')}
            </Tag>
          </Tooltip>
        );
      },
    },
    {
      title: '',
      dataIndex: 'operate',
      fixed: 'right',
      width: 200,
      render: (text, record, index) =>
        renderOperations(text, record, {
          setEditingUser,
          setShowEditUser,
          showPromoteModal,
          showDemoteModal,
          showEnableDisableModal,
          showDeleteModal,
          showResetPasskeyModal,
          showResetTwoFAModal,
          showUserSubscriptionsModal,
          t,
        }),
    },
  ];
};
