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

import React, { useState, useRef, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Avatar, Button, Popover, Typography } from '@douyinfe/semi-ui';
import { ChevronDown } from 'lucide-react';
import {
  IconExit,
  IconUserSetting,
  IconCreditCard,
  IconKey,
} from '@douyinfe/semi-icons';
import { stringToColor } from '../../../helpers';
import SkeletonWrapper from '../components/SkeletonWrapper';

const UserArea = ({
  userState,
  isLoading,
  isMobile,
  isSelfUseMode,
  logout,
  navigate,
  t,
}) => {
  const [visible, setVisible] = useState(false);
  const pendingVisibleChange = useRef(null);

  // 使用 useEffect 来处理状态更新，避免在渲染周期中同步调用 setState
  useEffect(() => {
    if (pendingVisibleChange.current !== null) {
      setVisible(pendingVisibleChange.current);
      pendingVisibleChange.current = null;
    }
  }, []);

  const handleVisibleChange = (newVisible) => {
    // 延迟到下一个 tick 执行，避免在 Popover 的渲染周期中同步调用 setState
    setTimeout(() => {
      setVisible(newVisible);
    }, 0);
  };

  if (isLoading) {
    return (
      <SkeletonWrapper
        loading={true}
        type='userArea'
        width={50}
        isMobile={isMobile}
      />
    );
  }

  if (userState.user) {
    const menuItems = [
      {
        key: 'personal',
        icon: (
          <IconUserSetting
            size='small'
            className='text-gray-500 dark:text-gray-400'
          />
        ),
        label: t('个人设置'),
        onClick: () => navigate('/console/personal'),
      },
      {
        key: 'token',
        icon: (
          <IconKey
            size='small'
            className='text-gray-500 dark:text-gray-400'
          />
        ),
        label: t('令牌管理'),
        onClick: () => navigate('/console/token'),
      },
      {
        key: 'topup',
        icon: (
          <IconCreditCard
            size='small'
            className='text-gray-500 dark:text-gray-400'
          />
        ),
        label: t('钱包管理'),
        onClick: () => navigate('/console/topup'),
      },
      {
        key: 'logout',
        icon: (
          <IconExit
            size='small'
            className='text-gray-500 dark:text-gray-400'
          />
        ),
        label: t('退出'),
        onClick: logout,
        danger: true,
      },
    ];

    const content = (
      <div className='!bg-semi-color-bg-overlay !border-semi-color-border !shadow-lg !rounded-lg dark:!bg-gray-700 dark:!border-gray-600 min-w-[140px]'>
        {menuItems.map((item) => (
          <div
            key={item.key}
            onClick={() => {
              item.onClick();
              setVisible(false);
            }}
            className={`flex items-center gap-2 px-3 py-1.5 cursor-pointer rounded-md mx-1 my-0.5 !text-sm !text-semi-color-text-0 dark:!text-gray-200 ${
              item.danger
                ? 'hover:!bg-red-500 hover:!text-white'
                : 'hover:!bg-semi-color-fill-1 dark:hover:!bg-gray-600'
            }`}
          >
            {item.icon}
            <span>{item.label}</span>
          </div>
        ))}
      </div>
    );

    return (
      <Popover
        visible={visible}
        onVisibleChange={handleVisibleChange}
        position='bottomRight'
        trigger='click'
        content={content}
        showArrow={false}
        spacing={4}
      >
        <Button
          theme='borderless'
          type='tertiary'
          onClick={() => setVisible((v) => !v)}
          className='flex items-center gap-1.5 !p-1 !rounded-full hover:!bg-semi-color-fill-1 dark:hover:!bg-gray-700 !bg-semi-color-fill-0 dark:!bg-semi-color-fill-1 dark:hover:!bg-semi-color-fill-2'
        >
          <Avatar
            size='extra-small'
            color={stringToColor(userState.user.username)}
            className='mr-1'
          >
            {userState.user.username[0].toUpperCase()}
          </Avatar>
          <span className='hidden md:inline'>
            <Typography.Text className='!text-xs !font-medium !text-semi-color-text-1 dark:!text-gray-300 mr-1'>
              {userState.user.username}
            </Typography.Text>
          </span>
          <ChevronDown
            size={14}
            className='text-xs text-semi-color-text-2 dark:text-gray-400'
          />
        </Button>
      </Popover>
    );
  } else {
    const showRegisterButton = !isSelfUseMode;

    const commonSizingAndLayoutClass =
      'flex items-center justify-center !py-[10px] !px-1.5';

    const loginButtonSpecificStyling =
      '!bg-semi-color-fill-0 dark:!bg-semi-color-fill-1 hover:!bg-semi-color-fill-1 dark:hover:!bg-gray-700 transition-colors';
    let loginButtonClasses = `${commonSizingAndLayoutClass} ${loginButtonSpecificStyling}`;

    let registerButtonClasses = `${commonSizingAndLayoutClass}`;

    const loginButtonTextSpanClass =
      '!text-xs !text-semi-color-text-1 dark:!text-gray-300 !p-1.5';
    const registerButtonTextSpanClass = '!text-xs !text-white !p-1.5';

    if (showRegisterButton) {
      if (isMobile) {
        loginButtonClasses += ' !rounded-full';
      } else {
        loginButtonClasses += ' !rounded-l-full !rounded-r-none';
      }
      registerButtonClasses += ' !rounded-r-full !rounded-l-none';
    } else {
      loginButtonClasses += ' !rounded-full';
    }

    return (
      <div className='flex items-center'>
        <Link to='/login' className='flex'>
          <Button
            theme='borderless'
            type='tertiary'
            className={loginButtonClasses}
          >
            <span className={loginButtonTextSpanClass}>{t('登录')}</span>
          </Button>
        </Link>
        {showRegisterButton && (
          <div className='hidden md:block'>
            <Link to='/register' className='flex -ml-px'>
              <Button
                theme='solid'
                type='primary'
                className={registerButtonClasses}
              >
                <span className={registerButtonTextSpanClass}>{t('注册')}</span>
              </Button>
            </Link>
          </div>
        )}
      </div>
    );
  }
};

export default UserArea;
