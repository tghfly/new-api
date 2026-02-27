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

import React, { useState } from 'react';
import { Button, Popover } from '@douyinfe/semi-ui';
import { Languages } from 'lucide-react';

const LanguageSelector = ({ currentLang, onLanguageChange, t }) => {
  const [visible, setVisible] = useState(false);

  const languages = [
    { key: 'zh-CN', label: '简体中文' },
    { key: 'zh-TW', label: '繁體中文' },
    { key: 'en', label: 'English' },
    { key: 'fr', label: 'Français' },
    { key: 'ja', label: '日本語' },
    { key: 'ru', label: 'Русский' },
    { key: 'vi', label: 'Tiếng Việt' },
  ];

  const handleSelect = (key) => {
    onLanguageChange(key);
    setVisible(false);
  };

  const getItemClassName = (key) =>
    `!px-3 !py-1.5 !text-sm !text-semi-color-text-0 dark:!text-gray-200 ${
      currentLang === key
        ? '!bg-semi-color-primary-light-default dark:!bg-blue-600 !font-semibold'
        : 'hover:!bg-semi-color-fill-1 dark:hover:!bg-gray-600'
    }`;

  const content = (
    <div className='!bg-semi-color-bg-overlay !border-semi-color-border !shadow-lg !rounded-lg dark:!bg-gray-700 dark:!border-gray-600 min-w-[120px]'>
      {languages.map((lang) => (
        <div
          key={lang.key}
          onClick={() => handleSelect(lang.key)}
          className={`px-3 py-1.5 cursor-pointer rounded-md mx-1 my-0.5 ${getItemClassName(
            lang.key,
          )}`}
        >
          {lang.label}
        </div>
      ))}
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
        icon={<Languages size={18} />}
        aria-label={t('common.changeLanguage')}
        theme='borderless'
        type='tertiary'
        onClick={() => setVisible((v) => !v)}
        className='!p-1.5 !text-current focus:!bg-semi-color-fill-1 dark:focus:!bg-gray-700 !rounded-full !bg-semi-color-fill-0 dark:!bg-semi-color-fill-1 hover:!bg-semi-color-fill-1 dark:hover:!bg-semi-color-fill-2'
      />
    </Popover>
  );
};

export default LanguageSelector;
