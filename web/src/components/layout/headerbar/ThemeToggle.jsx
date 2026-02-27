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
import { Button, Popover } from '@douyinfe/semi-ui';
import { Sun, Moon, Monitor } from 'lucide-react';
import { useActualTheme } from '../../../context/Theme';

const ThemeToggle = ({ theme, onThemeToggle, t }) => {
  const actualTheme = useActualTheme();
  const [visible, setVisible] = useState(false);

  const themeOptions = useMemo(
    () => [
      {
        key: 'light',
        icon: <Sun size={18} />,
        buttonIcon: <Sun size={18} />,
        label: t('浅色模式'),
        description: t('始终使用浅色主题'),
      },
      {
        key: 'dark',
        icon: <Moon size={18} />,
        buttonIcon: <Moon size={18} />,
        label: t('深色模式'),
        description: t('始终使用深色主题'),
      },
      {
        key: 'auto',
        icon: <Monitor size={18} />,
        buttonIcon: <Monitor size={18} />,
        label: t('自动模式'),
        description: t('跟随系统主题设置'),
      },
    ],
    [t],
  );

  const getItemClassName = (isSelected) =>
    isSelected
      ? '!bg-semi-color-primary-light-default !font-semibold'
      : 'hover:!bg-semi-color-fill-1';

  const currentButtonIcon = useMemo(() => {
    const currentOption = themeOptions.find((option) => option.key === theme);
    return currentOption?.buttonIcon || themeOptions[2].buttonIcon;
  }, [theme, themeOptions]);

  const handleSelect = (key) => {
    onThemeToggle(key);
    setVisible(false);
  };

  const content = (
    <div className='min-w-[160px] !bg-semi-color-bg-overlay !border-semi-color-border !shadow-lg !rounded-lg dark:!bg-gray-700 dark:!border-gray-600'>
      {themeOptions.map((option) => (
        <div
          key={option.key}
          onClick={() => handleSelect(option.key)}
          className={`flex items-center gap-2 px-3 py-2 cursor-pointer rounded-md mx-1 my-0.5 ${getItemClassName(
            theme === option.key,
          )}`}
        >
          <span className='flex-shrink-0'>{option.icon}</span>
          <div className='flex flex-col'>
            <span className='text-sm !text-semi-color-text-0 dark:!text-gray-200'>
              {option.label}
            </span>
            <span className='text-xs text-semi-color-text-2'>
              {option.description}
            </span>
          </div>
        </div>
      ))}

      {theme === 'auto' && (
        <>
          <div className='border-t border-semi-color-border dark:border-gray-600 my-1' />
          <div className='px-3 py-2 text-xs text-semi-color-text-2'>
            {t('当前跟随系统')}：
            {actualTheme === 'dark' ? t('深色') : t('浅色')}
          </div>
        </>
      )}
    </div>
  );

  return (
    <Popover
      visible={visible}
      onVisibleChange={setVisible}
      position='bottomRight'
      trigger='click'
      content={content}
      showArrow={false}
      spacing={4}
    >
      <Button
        icon={currentButtonIcon}
        aria-label={t('切换主题')}
        theme='borderless'
        type='tertiary'
        onClick={() => setVisible((v) => !v)}
        className='!p-1.5 !text-current focus:!bg-semi-color-fill-1 !rounded-full !bg-semi-color-fill-0 hover:!bg-semi-color-fill-1'
      />
    </Popover>
  );
};

export default ThemeToggle;
