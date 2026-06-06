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
import { Modal, Tabs } from '@douyinfe/semi-ui';
import { useTranslation } from 'react-i18next';
import CodeViewer from '@/components/playground/CodeViewer';

const { TabPane } = Tabs;

const CHAT_VISION_EXAMPLE = `curl --location --request POST 'http://192.168.171.166:23370/v1/chat/completions' \\
  --header 'Content-Type: application/json' \\
  --header 'Authorization: Bearer sk-XMTCWJqG2GkU45rOD54a8843A80b46DaA7400696E721698c' \\
  --data-raw '{
    "model": "InternVL3-14B-AWQ",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "请描述这张图片的内容"
          },
          {
            "type": "image_url",
            "image_url": {
              "url": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAAAAAAAD..."
            }
          }
        ]
      }
    ],
    "max_tokens": 512,
    "temperature": 0.7,
    "stream": false
  }'`;

const CHAT_SIMPLE_EXAMPLE = `curl --location --request POST 'http://192.168.171.166:23370/v1/chat/completions' \\
  --header 'Content-Type: application/json' \\
  --header 'Authorization: Bearer sk-XMTCWJqG2GkU45rOD54a8843A80b46DaA7400696E721698c' \\
  --data-raw '{
      "model": "Qwen3-30B-A3B-Thinking-2507",
      "messages": [
          {
              "role": "user",
              "content": "你是谁？"
          }
      ],
      "temperature": 0.7,
      "top_p": 0.9,
      "stream": true
  }'`;

const EMBEDDING_EXAMPLE = `curl --location --request POST 'http://192.168.171.166:23370/v1/embeddings' \\
  --header 'Content-Type: application/json' \\
  --header 'Authorization: Bearer sk-XMTCWJqG2GkU45rOD54a8843A80b46DaA7400696E721698c' \\
  --data-raw '{
      "model": "Qwen3-Embedding-0.6B",
      "input": [
          "文本1",
          "文本2"
      ]
  }'`;

const RERANK_EXAMPLE = `curl --location --request POST 'http://192.168.171.166:23370/v1/rerank' \\
  --header 'Content-Type: application/json' \\
  --header 'Authorization: Bearer sk-XMTCWJqG2GkU45rOD54a8843A80b46DaA7400696E721698c' \\
  --data-raw '{
      "model": "bge-reranker-v2-m3",
      "query": "机器学习的最佳实践",
      "documents": [
          "介绍深度学习的基础知识",
          "机器学习中的监督学习和非监督学习",
          "机器学习在工业界的应用案例"
      ]
  }'`;

const ExampleModal = (props) => {
  const { t } = useTranslation();
  const { visible, handleClose } = props;

  return (
    <Modal
      title={t('API 调用示例')}
      visible={visible}
      onCancel={handleClose}
      width={860}
      footer={
        <div>
        </div>
      }
    >
      <Tabs type='line' defaultActiveKey='chat-vision'>
        <TabPane
          tab={t('多模态对话')}
          itemKey='chat-vision'
        >
          <div style={{ height: '420px' }}>
            <CodeViewer content={CHAT_VISION_EXAMPLE} title='chat-vision' language='bash' />
          </div>
        </TabPane>
        <TabPane
          tab={t('普通对话')}
          itemKey='chat-simple'
        >
          <div style={{ height: '420px' }}>
            <CodeViewer content={CHAT_SIMPLE_EXAMPLE} title='chat-simple' language='bash' />
          </div>
        </TabPane>
        <TabPane
          tab={t('向量嵌入')}
          itemKey='embedding'
        >
          <div style={{ height: '420px' }}>
            <CodeViewer content={EMBEDDING_EXAMPLE} title='embedding' language='bash' />
          </div>
        </TabPane>
        <TabPane
          tab={t('重排序')}
          itemKey='rerank'
        >
          <div style={{ height: '420px' }}>
            <CodeViewer content={RERANK_EXAMPLE} title='rerank' language='bash' />
          </div>
        </TabPane>
      </Tabs>
    </Modal>
  );
};

export default ExampleModal;
