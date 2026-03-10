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
import ChannelsTable from '../../components/table/channels';
import { useEmbeddedMode } from '../../hooks/common/useEmbeddedMode';
import { useSearchParams } from 'react-router-dom';

const File = () => {
  const isEmbedded = useEmbeddedMode();
  const topMarginClass = isEmbedded ? '' : 'mt-[60px]';
  const [searchParams] = useSearchParams();
  const action = searchParams.get('action');
  const inferenceServiceId = searchParams.get('inference_service_id');
  const modelRegistryId = searchParams.get('model_registry_id');

  return (
    <div className={`${topMarginClass} px-2`}>
      <ChannelsTable 
        autoAction={action}
        inferenceServiceId={inferenceServiceId}
        modelRegistryId={modelRegistryId}
        isEmbedded={isEmbedded}
      />
    </div>
  );
};

export default File;
