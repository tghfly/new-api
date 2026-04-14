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

import React, { useEffect, useState } from 'react';
import { Layout, TabPane, Tabs } from '@douyinfe/semi-ui';
import { useNavigate, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  Settings,
  Calculator,
  Gauge,
  Shapes,
  Cog,
  MoreHorizontal,
  LayoutDashboard,
  MessageSquare,
  Palette,
  CreditCard,
  Server,
  Activity,
} from 'lucide-react';

import SystemSetting from '../../components/settings/SystemSetting';
import { isRoot, hasSSOPerm } from '../../helpers';
import OtherSetting from '../../components/settings/OtherSetting';
import OperationSetting from '../../components/settings/OperationSetting';
import RateLimitSetting from '../../components/settings/RateLimitSetting';
import ModelSetting from '../../components/settings/ModelSetting';
import DashboardSetting from '../../components/settings/DashboardSetting';
import RatioSetting from '../../components/settings/RatioSetting';
import ChatsSetting from '../../components/settings/ChatsSetting';
import DrawingSetting from '../../components/settings/DrawingSetting';
import PaymentSetting from '../../components/settings/PaymentSetting';
import ModelDeploymentSetting from '../../components/settings/ModelDeploymentSetting';
import PerformanceSetting from '../../components/settings/PerformanceSetting';
import { useEmbeddedMode } from '../../hooks/common/useEmbeddedMode';

const Setting = () => {
  const isEmbedded = useEmbeddedMode();
  const topMarginClass = isEmbedded ? '' : 'mt-[60px]';
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const [tabActiveKey, setTabActiveKey] = useState('1');
  let panes = [];

  if (isRoot()) {
    // 运营设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:operation') || hasSSOPerm('b:ai-web:modelstation:setting:general')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <Settings size={18} />
          {t('运营设置')}
        </span>
      ),
      content: <OperationSetting />,
      itemKey: 'operation',
    });
    }
    // 仪表盘设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:dashboard')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <LayoutDashboard size={18} />
          {t('仪表盘设置')}
        </span>
      ),
      content: <DashboardSetting />,
      itemKey: 'dashboard',
    });
    }
    // 聊天设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:chat')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <MessageSquare size={18} />
          {t('聊天设置')}
        </span>
      ),
      content: <ChatsSetting />,
      itemKey: 'chats',
    });
    }
    // 绘图设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:drawing')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <Palette size={18} />
          {t('绘图设置')}
        </span>
      ),
      content: <DrawingSetting />,
      itemKey: 'drawing',
    });
    }
    // 支付设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:payment')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <CreditCard size={18} />
          {t('支付设置')}
        </span>
      ),
      content: <PaymentSetting />,
      itemKey: 'payment',
    });
    }
    // 分组与模型定价设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:ratio')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <Calculator size={18} />
          {t('分组与模型定价设置')}
        </span>
      ),
      content: <RatioSetting />,
      itemKey: 'ratio',
    });
    }
    // 速率限制设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:ratelimit')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <Gauge size={18} />
          {t('速率限制设置')}
        </span>
      ),
      content: <RateLimitSetting />,
      itemKey: 'ratelimit',
    });
    }
    // 模型相关设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:model')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <Shapes size={18} />
          {t('模型相关设置')}
        </span>
      ),
      content: <ModelSetting />,
      itemKey: 'models',
    });
    }
    // 模型部署设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:modeldeployment')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <Server size={18} />
          {t('模型部署设置')}
        </span>
      ),
      content: <ModelDeploymentSetting />,
      itemKey: 'model-deployment',
    });
    }
    // 性能设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:performance')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <Activity size={18} />
          {t('性能设置')}
        </span>
      ),
      content: <PerformanceSetting />,
      itemKey: 'performance',
    });
    }
    // 系统设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:system')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <Cog size={18} />
          {t('系统设置')}
        </span>
      ),
      content: <SystemSetting />,
      itemKey: 'system',
    });
    }
    // 其他设置
    if (hasSSOPerm('b:ai-web:modelstation:setting:other')) {
    panes.push({
      tab: (
        <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <MoreHorizontal size={18} />
          {t('其他设置')}
        </span>
      ),
      content: <OtherSetting />,
      itemKey: 'other',
    });
    }
  }
  const onChangeTab = (key) => {
    setTabActiveKey(key);
    navigate(`?tab=${key}`);
  };
  useEffect(() => {
    const searchParams = new URLSearchParams(window.location.search);
    const tab = searchParams.get('tab');
    if (tab) {
      setTabActiveKey(tab);
    } else {
      onChangeTab('operation');
    }
  }, [location.search]);
  return (
    <div className={`${topMarginClass} px-2`}>
      <Layout>
        <Layout.Content>
          <Tabs
            type='card'
            collapsible
            activeKey={tabActiveKey}
            onChange={(key) => onChangeTab(key)}
          >
            {panes.map((pane) => (
              <TabPane itemKey={pane.itemKey} tab={pane.tab} key={pane.itemKey}>
                {tabActiveKey === pane.itemKey && pane.content}
              </TabPane>
            ))}
          </Tabs>
        </Layout.Content>
      </Layout>
    </div>
  );
};

export default Setting;
