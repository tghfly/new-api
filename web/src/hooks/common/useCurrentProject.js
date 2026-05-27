import { useState, useEffect } from 'react';

// 从 localStorage 获取当前项目信息
export const getCurrentProjectInfo = () => {
  try {
    const projectStr = localStorage.getItem('saber-currentProject');
    if (projectStr) {
      const project = JSON.parse(projectStr);
      return {
        project_code: project?.content?.project_code || '',
        project_name: project?.content?.name || '',
        vdc_name: project?.content?.vdc_name || '',
      };
    }
  } catch (e) {
    // ignore
  }
  return { project_code: '', project_name: '', vdc_name: '' };
};

export const PROJECT_STORAGE_KEY = 'saber-currentProject';

/**
 * Hook: 获取当前项目信息
 * 支持响应项目切换
 */
export const useCurrentProject = () => {
  const [projectInfo, setProjectInfo] = useState(getCurrentProjectInfo);

  useEffect(() => {
    // 监听项目切换事件
    const handleStorageChange = (e) => {
      if (e.key === PROJECT_STORAGE_KEY || e.key === null) {
        setProjectInfo(getCurrentProjectInfo());
      }
    };

    // 监听自定义项目切换事件（前端可能不触发 storage 事件）
    const handleProjectChange = () => {
      setProjectInfo(getCurrentProjectInfo());
    };

    window.addEventListener('storage', handleStorageChange);
    window.addEventListener('projectChange', handleProjectChange);

    // 轮询检测项目变化（作为 fallback）
    const pollInterval = setInterval(() => {
      setProjectInfo(getCurrentProjectInfo());
    }, 1000);

    return () => {
      window.removeEventListener('storage', handleStorageChange);
      window.removeEventListener('projectChange', handleProjectChange);
      clearInterval(pollInterval);
    };
  }, []);

  return projectInfo;
};
