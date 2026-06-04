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

import React, { useState, useEffect, useCallback, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { API, showError, showSuccess, hasSSOPerm } from '../../../helpers';
import CardPro from '../../common/ui/CardPro';
import { useIsMobile } from '../../../hooks/common/useIsMobile';
import { createCardProPagination } from '../../../helpers/utils';
import {
  Button,
  Switch,
  Table,
  Tag,
  Space,
  SideSheet,
  Form,
  Input,
  InputNumber,
  Modal,
  Typography,
  Card,
  Avatar,
  Spin,
} from '@douyinfe/semi-ui';
import {
  IconSave,
  IconClose,
  IconSetting,
} from '@douyinfe/semi-icons';

const { Text, Title } = Typography;

const UserGroupsPage = () => {
  const { t } = useTranslation();
  const isMobile = useIsMobile();
  const [formApi, setFormApi] = useState(null);
  const [loading, setLoading] = useState(false);
  const [userGroups, setUserGroups] = useState([]);
  const [userCount, setUserCount] = useState(0);
  const [activePage, setActivePage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [showSideSheet, setShowSideSheet] = useState(false);
  const [editingGroup, setEditingGroup] = useState(null);
  const [formLoading, setFormLoading] = useState(false);
  const promotionRef = useRef(false);

  const loadUserGroups = useCallback(async () => {
    setLoading(true);
    try {
      const res = await API.get('/api/user_group/', {
        params: {
          page: activePage,
          page_size: pageSize,
        },
      });
      const { success, message: msg, data } = res.data;
      if (success) {
        setUserGroups(data.data || []);
        setUserCount(data.total_count || 0);
      } else {
        showError(msg || t('userGroups.loadFailed'));
      }
    } catch (error) {
      console.error('Error loading user groups:', error);
      showError(t('userGroups.loadFailed'));
    } finally {
      setLoading(false);
    }
  }, [activePage, pageSize, t]);

  useEffect(() => {
    loadUserGroups();
  }, [loadUserGroups]);

  const handlePageChange = (page) => {
    setActivePage(page);
  };

  const handlePageSizeChange = (size) => {
    setPageSize(size);
    setActivePage(1);
  };

  const handleAdd = () => {
    setEditingGroup(null);
    setShowSideSheet(true);
  };

  const handleEdit = (record) => {
    setEditingGroup(record);
    promotionRef.current = !!record.promotion;
    setShowSideSheet(true);
  };

  // 使用 useEffect 监听 showSideSheet 和 formApi 的变化，确保表单正确回填数据
  useEffect(() => {
    if (showSideSheet && formApi) {
      if (editingGroup) {
        // 编辑模式：回填数据
        formApi.setValues({
          ...editingGroup,
          min: editingGroup.min || 0,
          max: editingGroup.max || 0,
        });
      } else {
        // 新建模式：重置表单
        formApi.setValues({
          symbol: '',
          name: '',
          ratio: 1,
          api_rate_total: 0,
          api_rate_success: 1000,
          min: 0,
          max: 0,
        });
      }
    }
  }, [showSideSheet, formApi, editingGroup]);

  const [deleteModalVisible, setDeleteModalVisible] = useState(false);
  const [deleteModalId, setDeleteModalId] = useState(null);

  const handleDelete = (id) => {
    setDeleteModalId(id);
    setDeleteModalVisible(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      const res = await API.delete(`/api/user_group/${deleteModalId}`);
      const { success, message: msg } = res.data;
      if (success) {
        showSuccess(msg || t('userGroups.deleted'));
        loadUserGroups();
      } else {
        showError(msg || t('userGroups.delete'));
      }
    } catch (error) {
      console.error('Error deleting user group:', error);
      showError(t('userGroups.deleted'));
    }
    setDeleteModalVisible(false);
  };

  const handleToggleEnable = async (id, enable) => {
    try {
      const res = await API.put(`/api/user_group/${id}`, { enable });
      const { success, message: msg } = res.data;
      if (success) {
        showSuccess(t('userGroups.statusUpdated'));
        loadUserGroups();
      } else {
        showError(msg || t('userGroups.statusUpdated'));
      }
    } catch (error) {
      console.error('Error updating user group status:', error);
      showError(t('userGroups.statusUpdated'));
    }
  };

  const handleSubmit = async (values) => {
    setFormLoading(true);
    try {
      // 将字符串 'true'/'false' 转换为布尔值
      const submitValues = {
        ...values,
        public: editingGroup ? editingGroup.public : false,
        promotion: editingGroup ? promotionRef.current : false,
      };
      let res;
      if (editingGroup) {
        // 编辑时调用 PUT /api/user_group/（不带 id），id 放在请求体中
        res = await API.put('/api/user_group/', {
          ...submitValues,
          id: editingGroup.id,
        });
      } else {
        res = await API.post('/api/user_group/', submitValues);
      }
      const { success, message: msg } = res.data;
      if (success) {
        showSuccess(editingGroup ? t('userGroups.updated') : t('userGroups.created'));
        setShowSideSheet(false);
        loadUserGroups();
      } else {
        showError(msg || t('userGroups.saveFailed'));
      }
    } catch (error) {
      console.error('Error saving user group:', error);
      showError(t('userGroups.saveFailed'));
    } finally {
      setFormLoading(false);
    }
  };

  const columns = [
    {
      title: t('userGroups.userGroupId'),
      dataIndex: 'id',
      key: 'id',
      width: 80,
    },
    {
      title: t('userGroups.symbol'),
      dataIndex: 'symbol',
      key: 'symbol',
      width: 120,
    },
    {
      title: t('userGroups.name'),
      dataIndex: 'name',
      key: 'name',
      width: 140,
    },
    {
      title: t('userGroups.ratio'),
      dataIndex: 'ratio',
      key: 'ratio',
      width: 90,
      render: (ratio) => `${ratio}x`,
    },
    {
      title: t('userGroups.apiRateTotal'),
      dataIndex: 'api_rate_total',
      key: 'api_rate_total',
      width: 130,
      render: (rate) => rate === 0 ? t('userGroups.unlimited') : t('userGroups.apiRateValue', { rate }),
    },
    {
      title: t('userGroups.apiRateSuccess'),
      dataIndex: 'api_rate_success',
      key: 'api_rate_success',
      width: 130,
      render: (rate) => t('userGroups.apiRateValue', { rate }),
    },
    {
      title: t('userGroups.isEnabled'),
      dataIndex: 'enable',
      key: 'enable',
      width: 90,
      render: (enable, record) => (
        (hasSSOPerm('b:ai-web:modelstation:usergroup:enable') || hasSSOPerm('b:ai-web:modelstation:usergroup:disable')) && (
        <Switch
          checked={enable}
          onChange={(checked) => handleToggleEnable(record.id, checked)}
        />
        )
      ),
    },
    {
      title: t('操作'),
      key: 'actions',
      width: 140,
      fixed: 'right',
      render: (_, record) => (
        <Space>
          {hasSSOPerm('b:ai-web:modelstation:usergroup:edit') && (
          <Button
            type='tertiary'
            size='small'
            onClick={() => handleEdit(record)}
          >
            {t('编辑')}
          </Button>
          )}
          {hasSSOPerm('b:ai-web:modelstation:usergroup:delete') && (
          <Button
            type='danger'
            size='small'
            onClick={() => handleDelete(record.id)}
          >
            {t('删除')}
          </Button>
          )}
        </Space>
      ),
    },
  ];

  return (
    <>
      <CardPro
        type='type1'
        actionsArea={
          <div className='flex justify-between items-center w-full'>
            {hasSSOPerm('b:ai-web:modelstation:usergroup:create') && (
            <Button className='w-full md:w-auto' onClick={handleAdd} size='small'>
              {t('添加用户组')}
            </Button>
            )}
          </div>
        }
        paginationArea={createCardProPagination({
          currentPage: activePage,
          pageSize: pageSize,
          total: userCount,
          onPageChange: handlePageChange,
          onPageSizeChange: handlePageSizeChange,
          isMobile: isMobile,
          t: t,
        })}
        t={t}
      >
        <Table
          columns={columns}
          dataSource={userGroups}
          rowKey='id'
          loading={loading}
          pagination={false}
          scroll={{ x: 'max-content' }}
        />
      </CardPro>

      <Modal
        title={t('确定是否要删除此用户组？')}
        visible={deleteModalVisible}
        onCancel={() => setDeleteModalVisible(false)}
        onOk={handleDeleteConfirm}
        type='danger'
      >
        {t('删除用户组后，将不可恢复')}
      </Modal>

      <SideSheet
        placement={'left'}
        title={
          <Space>
            <Tag color='green' shape='circle'>
              {editingGroup ? t('编辑') : t('新建')}
            </Tag>
            <Title heading={4} className='m-0'>
              {editingGroup ? t('编辑用户组') : t('添加用户组')}
            </Title>
          </Space>
        }
        bodyStyle={{ padding: '0' }}
        visible={showSideSheet}
        width={isMobile ? '100%' : 600}
        footer={
          <div className='flex justify-end bg-white'>
            <Space>
              <Button
                theme='solid'
                onClick={() => formApi?.submitForm()}
                icon={<IconSave />}
                loading={formLoading}
              >
                {t('提交')}
              </Button>
              <Button
                theme='light'
                type='tertiary'
                onClick={() => setShowSideSheet(false)}
                icon={<IconClose />}
              >
                {t('取消')}
              </Button>
            </Space>
          </div>
        }
        closeIcon={null}
        onCancel={() => setShowSideSheet(false)}
        maskClosable={false}
      >
        <Spin spinning={formLoading}>
          <Form
            getFormApi={setFormApi}
            onSubmit={handleSubmit}
            onSubmitFail={(errs) => {
              const first = Object.values(errs)[0];
              if (first) showError(Array.isArray(first) ? first[0] : first);
            }}
          >
            <div className='p-2'>
              <Card className='!rounded-2xl shadow-sm border-0'>
                <div className='flex items-center mb-2'>
                  <Avatar size='small' color='blue' className='mr-2 shadow-md'>
                    <IconSetting size={16} />
                  </Avatar>
                  <div>
                    <Text className='text-lg font-medium'>
                      {t('分组信息')}
                    </Text>
                    <div className='text-xs text-gray-600'>
                      {editingGroup ? t('编辑用户组信息') : t('创建新用户组')}
                    </div>
                  </div>
                </div>

                <Form.Input
                  field='symbol'
                  label={t('标识')}
                  placeholder={t('请输入分组标识')}
                  rules={[{ required: true, message: t('请输入分组标识') }]}
                  disabled={!!editingGroup}
                  showClear
                />
                <Form.Input
                  field='name'
                  label={t('名称')}
                  placeholder={t('请输入分组名称')}
                  rules={[{ required: true, message: t('请输入分组名称') }]}
                  showClear
                />
                <Form.InputNumber
                  field='ratio'
                  label={t('倍率')}
                  placeholder={t('请输入倍率')}
                  rules={[{ required: true, message: t('请输入倍率') }]}
                  min={0}
                  step={0.1}
                  style={{ width: '100%' }}
                />
                <Form.InputNumber
                  field='api_rate_total'
                  label={t('userGroups.apiRateTotal')}
                  placeholder={t('userGroups.apiRateTotalPlaceholder')}
                  rules={[{ required: true, message: t('userGroups.apiRateTotalRequired') }]}
                  min={0}
                  style={{ width: '100%' }}
                />
                <Form.InputNumber
                  field='api_rate_success'
                  label={t('userGroups.apiRateSuccess')}
                  placeholder={t('userGroups.apiRateSuccessPlaceholder')}
                  rules={[{ required: true, message: t('userGroups.apiRateSuccessRequired') }]}
                  min={0}
                  style={{ width: '100%' }}
                />
              </Card>
            </div>
          </Form>
        </Spin>
      </SideSheet>
    </>
  );
};

export default UserGroupsPage;
