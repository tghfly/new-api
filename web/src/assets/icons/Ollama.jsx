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

const TITLE = 'Ollama';

const Mono = memo(({ size = '1em', style, ...rest }) => {
  return (
    <svg
      fill="currentColor"
      fillRule="evenodd"
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
        d="M12 24C6.477 24 2 19.523 2 14c0-3.314 1.789-6.23 4.5-7.732V3.5A1.5 1.5 0 017.5 2h9a1.5 1.5 0 011.5 1.5v2.768C20.211 7.77 22 10.686 22 14c0 5.523-4.477 10-10 10zm-1.5-16.5v2.768C7.789 7.77 6 10.686 6 14c0 3.866 3.134 7 7 7s7-3.134 7-7c0-3.314-1.789-6.23-4.5-7.732V3.5h-3z"
      />
    </svg>
  );
});

const Ollama = Mono;

// 添加其他可能的变体
Ollama.Mono = Mono;

// 添加颜色常量
Ollama.colorPrimary = '#000000';
Ollama.title = TITLE;

export default Ollama;