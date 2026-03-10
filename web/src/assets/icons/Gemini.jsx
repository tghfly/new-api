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

import React, { memo } from 'react';

const TITLE = 'Gemini';

// 简化版的 useFillId 钩子
const useFillId = (title) => {
  const id = `gemini-gradient-${title.toLowerCase()}`;
  const fill = `url(#${id})`;
  return { id, fill };
};

const Mono = memo(({ size = '1em', style, ...rest }) => {
  return (
    <svg
      height={size}
      style={{
        flex: 'none',
        lineHeight: 1,
        ...style,
      }}
      viewBox="0 0 24 24"
      width={size}
      xmlns="http://www.w3.org/2000/svg"
      {...rest}
    >
      <title>{TITLE}</title>
      <path
        d="M12 24A14.304 14.304 0 000 12 14.304 14.304 0 0012 0a14.305 14.305 0 0012 12 14.305 14.305 0 00-12 12"
        fill="currentColor"
        fillRule="nonzero"
      />
    </svg>
  );
});

const Color = memo(({ size = '1em', style, ...rest }) => {
  const { id, fill } = useFillId(TITLE);
  
  return (
    <svg
      height={size}
      style={{
        flex: 'none',
        lineHeight: 1,
        ...style,
      }}
      viewBox="0 0 24 24"
      width={size}
      xmlns="http://www.w3.org/2000/svg"
      {...rest}
    >
      <title>{TITLE}</title>
      <defs>
        <linearGradient
          id={id}
          x1="0%"
          x2="68.73%"
          y1="100%"
          y2="30.395%"
        >
          <stop offset="0%" stopColor="#1C7DFF" />
          <stop offset="52.021%" stopColor="#1C69FF" />
          <stop offset="100%" stopColor="#F0DCD6" />
        </linearGradient>
      </defs>
      <path
        d="M12 24A14.304 14.304 0 000 12 14.304 14.304 0 0012 0a14.305 14.305 0 0012 12 14.305 14.305 0 00-12 12"
        fill={fill}
        fillRule="nonzero"
      />
    </svg>
  );
});

const Gemini = Mono;

// 添加其他可能的变体
Gemini.Mono = Mono;
Gemini.Color = Color;

// 添加颜色常量
Gemini.colorPrimary = '#1C7DFF';
Gemini.title = TITLE;

export default Gemini;