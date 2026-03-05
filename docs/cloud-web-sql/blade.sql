/*
 Navicat Premium Data Transfer

 Source Server         : 192.168.172.235-扶摇平台
 Source Server Type    : MySQL
 Source Server Version : 50737
 Source Host           : 192.168.172.11:3336
 Source Schema         : blade

 Target Server Type    : MySQL
 Target Server Version : 50737
 File Encoding         : 65001

 Date: 29/12/2025 11:41:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for blade_client
-- ----------------------------
DROP TABLE IF EXISTS `blade_client`;
CREATE TABLE `blade_client`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `client_id` varchar(48) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户端id',
  `client_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '客户端名称',
  `client_secret` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户端密钥',
  `resource_ids` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '资源集合',
  `scope` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'all' COMMENT '授权范围',
  `authorized_grant_types` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '授权类型',
  `web_server_redirect_uri` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '回调地址',
  `authorities` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '权限',
  `access_token_validity` int(11) NULL DEFAULT NULL COMMENT '令牌过期秒数',
  `refresh_token_validity` int(11) NULL DEFAULT NULL COMMENT '刷新令牌过期秒数',
  `additional_information` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '附加说明',
  `autoapprove` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '自动授权',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NOT NULL COMMENT '状态',
  `is_deleted` int(2) NOT NULL COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '客户端表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_code
-- ----------------------------
DROP TABLE IF EXISTS `blade_code`;
CREATE TABLE `blade_code`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `datasource_id` bigint(64) NULL DEFAULT NULL COMMENT '数据源主键',
  `service_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务名称',
  `code_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模块名称',
  `table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '表名',
  `table_prefix` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '表前缀',
  `pk_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主键名',
  `package_name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '后端包名',
  `base_mode` int(2) NULL DEFAULT NULL COMMENT '基础业务模式',
  `wrap_mode` int(2) NULL DEFAULT NULL COMMENT '包装器模式',
  `api_path` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '后端路径',
  `web_path` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '前端路径',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '代码生成表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_datasource
-- ----------------------------
DROP TABLE IF EXISTS `blade_datasource`;
CREATE TABLE `blade_datasource`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '名称',
  `driver_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '驱动类',
  `url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '连接地址',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名',
  `password` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '密码',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT NULL COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '数据源配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_dict
-- ----------------------------
DROP TABLE IF EXISTS `blade_dict`;
CREATE TABLE `blade_dict`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父主键',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '字典分类编码',
  `dict_key` int(2) NULL DEFAULT NULL COMMENT '字典值',
  `dict_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '字典名称',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '字典备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `create_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `tenant_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '租户id',
  `is_system` int(10) NULL DEFAULT 1 COMMENT '系统内置 1：是   0：否',
  `attribute_param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '拓展参数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '字典表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_func
-- ----------------------------
DROP TABLE IF EXISTS `blade_func`;
CREATE TABLE `blade_func`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sub_system_code` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL COMMENT '子系统编号',
  `url` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL COMMENT '功能点路径',
  `url_method` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL COMMENT '请求方式',
  `url_name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL COMMENT '路径名称',
  `permission` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL COMMENT '权限标识',
  `is_deleted` int(2) NULL DEFAULT NULL COMMENT '是否删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for blade_link
-- ----------------------------
DROP TABLE IF EXISTS `blade_link`;
CREATE TABLE `blade_link`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `url` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求地址',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `category` int(2) NULL DEFAULT NULL COMMENT '菜单类型',
  `is_open` int(2) NULL DEFAULT 1 COMMENT '是否打开新页面',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_user` bigint(64) NULL DEFAULT NULL,
  `update_user` bigint(64) NULL DEFAULT NULL,
  `status` tinyint(4) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1735291602549608450 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_log
-- ----------------------------
DROP TABLE IF EXISTS `blade_log`;
CREATE TABLE `blade_log`  (
  `id` bigint(64) NOT NULL COMMENT '编号',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '租户ID',
  `service_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT ' 服务ID',
  `server_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务器名',
  `server_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT ' 服务器IP地址',
  `env` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT ' 服务器环境',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '1' COMMENT '日志类型',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '日志标题',
  `method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作方式',
  `request_uri` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求URI',
  `user_agent` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户代理',
  `remote_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT ' 操作IP地址',
  `method_class` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法类',
  `method_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法名',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '操作提交的数据',
  `time` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT ' 执行时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT ' 创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'userId',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '接口日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for blade_log_api
-- ----------------------------
DROP TABLE IF EXISTS `blade_log_api`;
CREATE TABLE `blade_log_api`  (
  `id` bigint(64) NOT NULL COMMENT '编号',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `service_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务ID',
  `server_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务器名',
  `server_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务器IP地址',
  `env` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务器环境',
  `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '1' COMMENT '日志类型',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '日志标题',
  `method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作方式',
  `request_uri` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求URI',
  `user_agent` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户代理',
  `remote_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作IP地址',
  `method_class` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法类',
  `method_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法名',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '操作提交的数据',
  `time` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '执行时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '接口日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_log_api_type
-- ----------------------------
DROP TABLE IF EXISTS `blade_log_api_type`;
CREATE TABLE `blade_log_api_type`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `log_type_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '类型编码',
  `log_type_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '日志类型名',
  `log_type_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '日志类型描述',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 34613 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '接口日志类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for blade_log_error
-- ----------------------------
DROP TABLE IF EXISTS `blade_log_error`;
CREATE TABLE `blade_log_error`  (
  `id` bigint(64) NOT NULL COMMENT '编号',
  `log_id` bigint(64) NULL DEFAULT NULL,
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `service_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务ID',
  `server_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务器名',
  `server_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务器IP地址',
  `env` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '系统环境',
  `method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作方式',
  `request_uri` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求URI',
  `user_agent` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户代理',
  `stack_trace` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '堆栈',
  `exception_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '异常名',
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '异常信息',
  `line_number` int(11) NULL DEFAULT NULL COMMENT '错误行数',
  `remote_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作IP地址',
  `method_class` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法类',
  `file_name` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文件名',
  `method_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法名',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '操作提交的数据',
  `time` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '执行时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '错误日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_log_usual
-- ----------------------------
DROP TABLE IF EXISTS `blade_log_usual`;
CREATE TABLE `blade_log_usual`  (
  `id` bigint(64) NOT NULL COMMENT '编号',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `service_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务ID',
  `server_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务器名',
  `server_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '服务器IP地址',
  `env` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '系统环境',
  `log_level` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '日志级别',
  `log_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '日志业务id',
  `log_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '日志数据',
  `method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作方式',
  `request_uri` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求URI',
  `remote_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '操作IP地址',
  `method_class` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法类',
  `method_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '方法名',
  `user_agent` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户代理',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '操作提交的数据',
  `time` datetime NULL DEFAULT NULL COMMENT '执行时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '通用日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_menu
-- ----------------------------
DROP TABLE IF EXISTS `blade_menu`;
CREATE TABLE `blade_menu`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父级菜单',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单别名',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件地址',
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单资源',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `category` int(2) NULL DEFAULT NULL COMMENT '菜单类型',
  `ext_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单参数',
  `action` int(2) NULL DEFAULT 0 COMMENT '操作按钮类型',
  `is_open` int(2) NULL DEFAULT 1 COMMENT '是否打开新页面',
  `is_menu_show` int(2) NULL DEFAULT 1 COMMENT '是否菜单显示',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `is_expand` int(2) NULL DEFAULT 0 COMMENT '是否展开',
  `func_id` int(20) NULL DEFAULT NULL COMMENT '功能点id',
  `sub_system_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子系统编号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2599596787736264787 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_menu_20230706
-- ----------------------------
DROP TABLE IF EXISTS `blade_menu_20230706`;
CREATE TABLE `blade_menu_20230706`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父级菜单',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单别名',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件地址',
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单资源',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `category` int(2) NULL DEFAULT NULL COMMENT '菜单类型',
  `ext_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单参数',
  `action` int(2) NULL DEFAULT 0 COMMENT '操作按钮类型',
  `is_open` int(2) NULL DEFAULT 1 COMMENT '是否打开新页面',
  `is_menu_show` int(2) NULL DEFAULT 1 COMMENT '是否菜单显示',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `is_expand` int(2) NULL DEFAULT 0 COMMENT '是否展开',
  `func_id` int(20) NULL DEFAULT NULL COMMENT '功能点id',
  `sub_system_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子系统编号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_menu_20241108
-- ----------------------------
DROP TABLE IF EXISTS `blade_menu_20241108`;
CREATE TABLE `blade_menu_20241108`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父级菜单',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单别名',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件地址',
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单资源',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `category` int(2) NULL DEFAULT NULL COMMENT '菜单类型',
  `ext_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单参数',
  `action` int(2) NULL DEFAULT 0 COMMENT '操作按钮类型',
  `is_open` int(2) NULL DEFAULT 1 COMMENT '是否打开新页面',
  `is_menu_show` int(2) NULL DEFAULT 1 COMMENT '是否菜单显示',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `is_expand` int(2) NULL DEFAULT 0 COMMENT '是否展开',
  `func_id` int(20) NULL DEFAULT NULL COMMENT '功能点id',
  `sub_system_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子系统编号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2599596787736264771 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_menu_20250423
-- ----------------------------
DROP TABLE IF EXISTS `blade_menu_20250423`;
CREATE TABLE `blade_menu_20250423`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父级菜单',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单别名',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件地址',
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单资源',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `category` int(2) NULL DEFAULT NULL COMMENT '菜单类型',
  `ext_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单参数',
  `action` int(2) NULL DEFAULT 0 COMMENT '操作按钮类型',
  `is_open` int(2) NULL DEFAULT 1 COMMENT '是否打开新页面',
  `is_menu_show` int(2) NULL DEFAULT 1 COMMENT '是否菜单显示',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `is_expand` int(2) NULL DEFAULT 0 COMMENT '是否展开',
  `func_id` int(20) NULL DEFAULT NULL COMMENT '功能点id',
  `sub_system_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子系统编号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2599596787736264787 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_menu_20250704
-- ----------------------------
DROP TABLE IF EXISTS `blade_menu_20250704`;
CREATE TABLE `blade_menu_20250704`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父级菜单',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单别名',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件地址',
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单资源',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `category` int(2) NULL DEFAULT NULL COMMENT '菜单类型',
  `ext_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单参数',
  `action` int(2) NULL DEFAULT 0 COMMENT '操作按钮类型',
  `is_open` int(2) NULL DEFAULT 1 COMMENT '是否打开新页面',
  `is_menu_show` int(2) NULL DEFAULT 1 COMMENT '是否菜单显示',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `is_expand` int(2) NULL DEFAULT 0 COMMENT '是否展开',
  `func_id` int(20) NULL DEFAULT NULL COMMENT '功能点id',
  `sub_system_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子系统编号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2599596787736264787 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_menu_copy1
-- ----------------------------
DROP TABLE IF EXISTS `blade_menu_copy1`;
CREATE TABLE `blade_menu_copy1`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父级菜单',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单别名',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件地址',
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单资源',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `category` int(2) NULL DEFAULT NULL COMMENT '菜单类型',
  `ext_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单参数',
  `action` int(2) NULL DEFAULT 0 COMMENT '操作按钮类型',
  `is_open` int(2) NULL DEFAULT 1 COMMENT '是否打开新页面',
  `is_menu_show` int(2) NULL DEFAULT 1 COMMENT '是否菜单显示',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `is_expand` int(2) NULL DEFAULT 0 COMMENT '是否展开',
  `func_id` int(20) NULL DEFAULT NULL COMMENT '功能点id',
  `sub_system_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子系统编号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2599596787736264741 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_menu_copy2
-- ----------------------------
DROP TABLE IF EXISTS `blade_menu_copy2`;
CREATE TABLE `blade_menu_copy2`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父级菜单',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单别名',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件地址',
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单资源',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `category` int(2) NULL DEFAULT NULL COMMENT '菜单类型',
  `ext_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单参数',
  `action` int(2) NULL DEFAULT 0 COMMENT '操作按钮类型',
  `is_open` int(2) NULL DEFAULT 1 COMMENT '是否打开新页面',
  `is_menu_show` int(2) NULL DEFAULT 1 COMMENT '是否菜单显示',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `is_expand` int(2) NULL DEFAULT 0 COMMENT '是否展开',
  `func_id` int(20) NULL DEFAULT NULL COMMENT '功能点id',
  `sub_system_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子系统编号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2599596787736264741 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_menu_copy3
-- ----------------------------
DROP TABLE IF EXISTS `blade_menu_copy3`;
CREATE TABLE `blade_menu_copy3`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父级菜单',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单别名',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件地址',
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单资源',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `category` int(2) NULL DEFAULT NULL COMMENT '菜单类型',
  `ext_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单参数',
  `action` int(2) NULL DEFAULT 0 COMMENT '操作按钮类型',
  `is_open` int(2) NULL DEFAULT 1 COMMENT '是否打开新页面',
  `is_menu_show` int(2) NULL DEFAULT 1 COMMENT '是否菜单显示',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `is_expand` int(2) NULL DEFAULT 0 COMMENT '是否展开',
  `func_id` int(20) NULL DEFAULT NULL COMMENT '功能点id',
  `sub_system_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子系统编号',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2599596787736264771 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_notice
-- ----------------------------
DROP TABLE IF EXISTS `blade_notice`;
CREATE TABLE `blade_notice`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标题',
  `category` int(11) NULL DEFAULT NULL COMMENT '类型',
  `release_time` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '内容',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT NULL COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '通知公告表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_param
-- ----------------------------
DROP TABLE IF EXISTS `blade_param`;
CREATE TABLE `blade_param`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `param_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '参数名',
  `tenant_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `param_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '参数键',
  `param_value` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '参数值',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `uni_idx_teant_key_delete`(`tenant_id`, `param_key`, `is_deleted`) USING BTREE COMMENT '每个租户下key唯一'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '参数表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_param_copy1
-- ----------------------------
DROP TABLE IF EXISTS `blade_param_copy1`;
CREATE TABLE `blade_param_copy1`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `param_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '参数名',
  `tenant_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `param_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '参数键',
  `param_value` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '参数值',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '参数表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_post
-- ----------------------------
DROP TABLE IF EXISTS `blade_post`;
CREATE TABLE `blade_post`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `category` int(11) NULL DEFAULT NULL COMMENT '岗位类型',
  `post_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '岗位编号',
  `post_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '岗位名称',
  `sort` int(2) NULL DEFAULT NULL COMMENT '岗位排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '岗位描述',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_dept` bigint(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT NULL COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '岗位表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_role
-- ----------------------------
DROP TABLE IF EXISTS `blade_role`;
CREATE TABLE `blade_role`  (
  `appid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父主键',
  `role_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色名',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `role_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色别名',
  `is_global` int(11) NULL DEFAULT NULL COMMENT '是否全局角色',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `is_system` int(2) NULL DEFAULT 0 COMMENT '是否是系统内置角色',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_id`(`id`) USING BTREE,
  INDEX `idx_name`(`role_name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1912344289895895045 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_role_copy1
-- ----------------------------
DROP TABLE IF EXISTS `blade_role_copy1`;
CREATE TABLE `blade_role_copy1`  (
  `appid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `parent_id` bigint(64) NULL DEFAULT 0 COMMENT '父主键',
  `role_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色名',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `role_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色别名',
  `is_global` int(11) NULL DEFAULT NULL COMMENT '是否全局角色',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `is_system` int(2) NULL DEFAULT 0 COMMENT '是否是系统内置角色',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1857362784261238786 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `blade_role_menu`;
CREATE TABLE `blade_role_menu`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `menu_id` bigint(64) NULL DEFAULT NULL COMMENT '菜单id',
  `role_id` bigint(64) NULL DEFAULT NULL COMMENT '角色id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1914877327326433283 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_role_menu_copy3
-- ----------------------------
DROP TABLE IF EXISTS `blade_role_menu_copy3`;
CREATE TABLE `blade_role_menu_copy3`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `menu_id` bigint(64) NULL DEFAULT NULL COMMENT '菜单id',
  `role_id` bigint(64) NULL DEFAULT NULL COMMENT '角色id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1860937199706537987 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_tenant
-- ----------------------------
DROP TABLE IF EXISTS `blade_tenant`;
CREATE TABLE `blade_tenant`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '租户ID',
  `tenant_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '租户名称',
  `linkman` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系地址',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态(0:无效  1:正常   -1:待录入配额)',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `quota_id` int(11) NULL DEFAULT -1 COMMENT '配额ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `tenant_id`(`tenant_id`) USING BTREE,
  INDEX `quota_id`(`quota_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1912342315272097794 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '租户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_user
-- ----------------------------
DROP TABLE IF EXISTS `blade_user`;
CREATE TABLE `blade_user`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `account` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '账号',
  `password` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '密码',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '真名',
  `avatar` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
  `email` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机',
  `birthday` datetime NULL DEFAULT NULL COMMENT '生日',
  `sex` smallint(6) NULL DEFAULT NULL COMMENT '性别',
  `role_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色id',
  `dept_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门id',
  `post_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '岗位id',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `vdc_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `region_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_tenant` bit(1) NULL DEFAULT NULL COMMENT '是否租户',
  `last_login_time` datetime NULL DEFAULT NULL,
  `last_login_ip` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_black_user` int(10) NULL DEFAULT NULL,
  `is_used` int(10) NULL DEFAULT NULL,
  `is_first_login` int(10) NULL DEFAULT NULL,
  `login_count` int(11) NULL DEFAULT NULL COMMENT 'cube-studio:登录次数',
  `fail_login_count` int(11) NULL DEFAULT NULL COMMENT 'cube-studio:登录失败次数',
  `org` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'cube-studio: org',
  `out_ref` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部引用-如工号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2005474686655422466 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_user_20250103
-- ----------------------------
DROP TABLE IF EXISTS `blade_user_20250103`;
CREATE TABLE `blade_user_20250103`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `account` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '账号',
  `password` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '密码',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '真名',
  `avatar` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
  `email` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机',
  `birthday` datetime NULL DEFAULT NULL COMMENT '生日',
  `sex` smallint(6) NULL DEFAULT NULL COMMENT '性别',
  `role_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色id',
  `dept_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门id',
  `post_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '岗位id',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `vdc_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `region_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_tenant` bit(1) NULL DEFAULT NULL COMMENT '是否租户',
  `last_login_time` datetime NULL DEFAULT NULL,
  `last_login_ip` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_black_user` int(10) NULL DEFAULT NULL,
  `is_used` int(10) NULL DEFAULT NULL,
  `is_first_login` int(10) NULL DEFAULT NULL,
  `login_count` int(11) NULL DEFAULT NULL COMMENT 'cube-studio:登录次数',
  `fail_login_count` int(11) NULL DEFAULT NULL COMMENT 'cube-studio:登录失败次数',
  `org` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'cube-studio: org',
  `out_ref` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部引用-如工号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1874992901883949058 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_user_20250402
-- ----------------------------
DROP TABLE IF EXISTS `blade_user_20250402`;
CREATE TABLE `blade_user_20250402`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `account` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '账号',
  `password` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '密码',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '真名',
  `avatar` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
  `email` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机',
  `birthday` datetime NULL DEFAULT NULL COMMENT '生日',
  `sex` smallint(6) NULL DEFAULT NULL COMMENT '性别',
  `role_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色id',
  `dept_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门id',
  `post_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '岗位id',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `vdc_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `region_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_tenant` bit(1) NULL DEFAULT NULL COMMENT '是否租户',
  `last_login_time` datetime NULL DEFAULT NULL,
  `last_login_ip` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_black_user` int(10) NULL DEFAULT NULL,
  `is_used` int(10) NULL DEFAULT NULL,
  `is_first_login` int(10) NULL DEFAULT NULL,
  `login_count` int(11) NULL DEFAULT NULL COMMENT 'cube-studio:登录次数',
  `fail_login_count` int(11) NULL DEFAULT NULL COMMENT 'cube-studio:登录失败次数',
  `org` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'cube-studio: org',
  `out_ref` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部引用-如工号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1907246385282674690 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_user_20250509
-- ----------------------------
DROP TABLE IF EXISTS `blade_user_20250509`;
CREATE TABLE `blade_user_20250509`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `account` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '账号',
  `password` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '密码',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '真名',
  `avatar` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
  `email` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机',
  `birthday` datetime NULL DEFAULT NULL COMMENT '生日',
  `sex` smallint(6) NULL DEFAULT NULL COMMENT '性别',
  `role_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色id',
  `dept_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门id',
  `post_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '岗位id',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `vdc_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `region_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_tenant` bit(1) NULL DEFAULT NULL COMMENT '是否租户',
  `last_login_time` datetime NULL DEFAULT NULL,
  `last_login_ip` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_black_user` int(10) NULL DEFAULT NULL,
  `is_used` int(10) NULL DEFAULT NULL,
  `is_first_login` int(10) NULL DEFAULT NULL,
  `login_count` int(11) NULL DEFAULT NULL COMMENT 'cube-studio:登录次数',
  `fail_login_count` int(11) NULL DEFAULT NULL COMMENT 'cube-studio:登录失败次数',
  `org` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'cube-studio: org',
  `out_ref` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部引用-如工号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1907259368297721858 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_user_20250827
-- ----------------------------
DROP TABLE IF EXISTS `blade_user_20250827`;
CREATE TABLE `blade_user_20250827`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `account` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '账号',
  `password` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '密码',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '真名',
  `avatar` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
  `email` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机',
  `birthday` datetime NULL DEFAULT NULL COMMENT '生日',
  `sex` smallint(6) NULL DEFAULT NULL COMMENT '性别',
  `role_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色id',
  `dept_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门id',
  `post_id` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '岗位id',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `vdc_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `region_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_tenant` bit(1) NULL DEFAULT NULL COMMENT '是否租户',
  `last_login_time` datetime NULL DEFAULT NULL,
  `last_login_ip` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_black_user` int(10) NULL DEFAULT NULL,
  `is_used` int(10) NULL DEFAULT NULL,
  `is_first_login` int(10) NULL DEFAULT NULL,
  `login_count` int(11) NULL DEFAULT NULL COMMENT 'cube-studio:登录次数',
  `fail_login_count` int(11) NULL DEFAULT NULL COMMENT 'cube-studio:登录失败次数',
  `org` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'cube-studio: org',
  `out_ref` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部引用-如工号',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1960509597267681282 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_user_ldap
-- ----------------------------
DROP TABLE IF EXISTS `blade_user_ldap`;
CREATE TABLE `blade_user_ldap`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `user_id` bigint(11) NOT NULL,
  `dn` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `cn` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `uid` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_user_vdc
-- ----------------------------
DROP TABLE IF EXISTS `blade_user_vdc`;
CREATE TABLE `blade_user_vdc`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint(64) NULL DEFAULT NULL COMMENT '用户id',
  `vdc_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'VdcCode',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户Vdc权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_visual
-- ----------------------------
DROP TABLE IF EXISTS `blade_visual`;
CREATE TABLE `blade_visual`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '大屏标题',
  `background_url` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '大屏背景',
  `category` int(2) NULL DEFAULT NULL COMMENT '大屏类型',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发布密码',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_dept` bigint(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NOT NULL COMMENT '状态',
  `is_deleted` int(2) NOT NULL COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '可视化表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_visual_category
-- ----------------------------
DROP TABLE IF EXISTS `blade_visual_category`;
CREATE TABLE `blade_visual_category`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `category_key` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分类键值',
  `category_value` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分类名称',
  `is_deleted` int(2) NOT NULL DEFAULT 0 COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '可视化分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_visual_config
-- ----------------------------
DROP TABLE IF EXISTS `blade_visual_config`;
CREATE TABLE `blade_visual_config`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `visual_id` bigint(64) NULL DEFAULT NULL COMMENT '可视化表主键',
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '配置json',
  `component` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '组件json',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '可视化配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for blade_visual_map
-- ----------------------------
DROP TABLE IF EXISTS `blade_visual_map`;
CREATE TABLE `blade_visual_map`  (
  `id` bigint(64) NOT NULL COMMENT '主键',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地图名称',
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '地图数据',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '可视化地图配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for busi_group
-- ----------------------------
DROP TABLE IF EXISTS `busi_group`;
CREATE TABLE `busi_group`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '租户ID',
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `parent_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '',
  `is_project` int(2) NULL DEFAULT 0,
  `label_enable` tinyint(1) NOT NULL DEFAULT 0,
  `label_value` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT 'if label_enable: label_value can not be blank',
  `create_at` bigint(20) NOT NULL DEFAULT 0,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  `update_at` bigint(20) NOT NULL DEFAULT 0,
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cmdb_logo
-- ----------------------------
DROP TABLE IF EXISTS `cmdb_logo`;
CREATE TABLE `cmdb_logo`  (
  `logo_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'logo ID',
  `logo_path` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'logo路径',
  `logo_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'logo编码',
  `logo_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'logo名称',
  `logo_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'logo状态(0:初始  10:生效)',
  `crt_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`logo_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'LOGO表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for cmdb_model
-- ----------------------------
DROP TABLE IF EXISTS `cmdb_model`;
CREATE TABLE `cmdb_model`  (
  `model_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '模型id',
  `group_id` bigint(20) NULL DEFAULT NULL,
  `model_logo_id` bigint(20) NULL DEFAULT NULL COMMENT '模型logo ID',
  `model_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '模型编码',
  `model_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '模型名称',
  `model_status` tinyint(4) NULL DEFAULT NULL COMMENT '模型状态',
  `model_desc` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '描述',
  `crt_time` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `user_id` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  PRIMARY KEY (`model_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 68 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '模型管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for cmdb_model_dialog
-- ----------------------------
DROP TABLE IF EXISTS `cmdb_model_dialog`;
CREATE TABLE `cmdb_model_dialog`  (
  `dialog_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '弹层ID',
  `dialog_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '弹层编码',
  `dialog_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '弹层名称',
  `model_form_id` bigint(20) NOT NULL COMMENT '模型表单ID',
  `dialog_content` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '弹层内容',
  `tenant_id` bigint(20) NOT NULL COMMENT '租户ID',
  PRIMARY KEY (`dialog_id`) USING BTREE,
  INDEX `model_form_id`(`model_form_id`) USING BTREE,
  INDEX `dialog_code`(`dialog_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for cmdb_model_form
-- ----------------------------
DROP TABLE IF EXISTS `cmdb_model_form`;
CREATE TABLE `cmdb_model_form`  (
  `model_form_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '表单模板ID',
  `model_id` bigint(20) NOT NULL COMMENT '模型id',
  `model_form_content` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '表单模型内容',
  `crt_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `user_id` bigint(20) NOT NULL COMMENT '创建人',
  `tenant_id` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '租户ID',
  PRIMARY KEY (`model_form_id`) USING BTREE,
  UNIQUE INDEX `model_id`(`model_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 50 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '模型表单模板' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for cmdb_resource_group
-- ----------------------------
DROP TABLE IF EXISTS `cmdb_resource_group`;
CREATE TABLE `cmdb_resource_group`  (
  `group_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `group_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分类名称',
  `group_icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分类icon',
  `group_level` tinyint(4) NULL DEFAULT NULL COMMENT '分类层级',
  `parent_group_id` bigint(20) NULL DEFAULT NULL COMMENT '上级分类',
  `crt_time` timestamp NULL DEFAULT NULL COMMENT '创建时间',
  `user_id` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `is_deleted` int(2) NULL DEFAULT 0,
  PRIMARY KEY (`group_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '资源分类' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for engeff_agent_day
-- ----------------------------
DROP TABLE IF EXISTS `engeff_agent_day`;
CREATE TABLE `engeff_agent_day`  (
  `dayid` date NOT NULL COMMENT '日期，每天一次，重复覆盖',
  `ident` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT '主机唯一键 资源池-主机名-IP',
  `res_pool_id` bigint(20) NULL DEFAULT 1 COMMENT '资源池',
  `host_name` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT '1' COMMENT '主机名',
  `ip` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT '1' COMMENT 'IP',
  `system_load` decimal(15, 8) NULL DEFAULT 0.00000000 COMMENT '系统负载',
  `system_n_cpus` int(11) NULL DEFAULT 1 COMMENT 'CPU数',
  `mem_total` bigint(20) NULL DEFAULT 0 COMMENT '总内存',
  `mem_used_percent` decimal(15, 10) NULL DEFAULT 0.0000000000 COMMENT '内存使用率',
  `disk_total` bigint(20) NULL DEFAULT 0 COMMENT '总磁盘',
  `data_disk_total` bigint(20) NULL DEFAULT 0 COMMENT '数据盘总容量',
  `data_disk_used` bigint(20) NULL DEFAULT 0 COMMENT '数据盘使用',
  `sys_disk_total` bigint(20) NULL DEFAULT 0 COMMENT '系统盘总容量',
  `sys_disk_used` bigint(20) NULL DEFAULT 0 COMMENT '系统盘使用',
  `system_eval_cost` decimal(15, 2) NULL DEFAULT 0.00 COMMENT '使用有效费用',
  `system_used_cost` decimal(15, 2) NULL DEFAULT 0.00 COMMENT '系统占用费用',
  `cpu_eval_rate` decimal(15, 12) UNSIGNED ZEROFILL NULL DEFAULT 000.000000000000 COMMENT 'cpu有效使用率',
  `mem_eval_rate` decimal(15, 12) NULL DEFAULT 0.000000000000 COMMENT 'mem有效使用率',
  `disk_eval_rate` decimal(15, 12) UNSIGNED ZEROFILL NULL DEFAULT 000.000000000000 COMMENT '磁盘有效使用率',
  PRIMARY KEY (`dayid`, `ident`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for et_activity_history
-- ----------------------------
DROP TABLE IF EXISTS `et_activity_history`;
CREATE TABLE `et_activity_history`  (
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `cause_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  `describe_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  `begin_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `server_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  `ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for exa_file_chunks
-- ----------------------------
DROP TABLE IF EXISTS `exa_file_chunks`;
CREATE TABLE `exa_file_chunks`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `created_at` datetime NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT NULL,
  `deleted_at` datetime NULL DEFAULT NULL,
  `exa_file_id` bigint(20) UNSIGNED NULL DEFAULT NULL,
  `file_chunk_number` bigint(20) NULL DEFAULT NULL,
  `file_chunk_path` varchar(256) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exa_file_chunks_deleted_at`(`deleted_at`) USING BTREE,
  INDEX `fk_exa_files_exa_file_chunk`(`exa_file_id`) USING BTREE,
  CONSTRAINT `fk_exa_files_exa_file_chunk` FOREIGN KEY (`exa_file_id`) REFERENCES `exa_files` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for exa_files
-- ----------------------------
DROP TABLE IF EXISTS `exa_files`;
CREATE TABLE `exa_files`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `created_at` datetime NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT NULL,
  `deleted_at` datetime NULL DEFAULT NULL,
  `file_name` varchar(256) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `file_md5` varchar(256) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `file_path` varchar(256) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `chunk_total` bigint(20) NULL DEFAULT NULL,
  `is_finish` tinyint(1) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exa_files_deleted_at`(`deleted_at`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for net_chain
-- ----------------------------
DROP TABLE IF EXISTS `net_chain`;
CREATE TABLE `net_chain`  (
  `res_pool_id` bigint(20) NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  PRIMARY KEY (`res_pool_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for patrol_history
-- ----------------------------
DROP TABLE IF EXISTS `patrol_history`;
CREATE TABLE `patrol_history`  (
  `history_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `patrol_plan_id` bigint(20) NOT NULL COMMENT '计划id',
  `xxl_logid` bigint(20) NULL DEFAULT NULL,
  `run_time` datetime NOT NULL COMMENT '执行开始时间',
  `end_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '执行结束时间',
  `device_ident` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT '设备标识',
  `device_ip` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL COMMENT '设备ip',
  `patrol_item_code` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT '巡检项code',
  `device_sub_ident` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL COMMENT '设备内子设备标识',
  `patrol_item_value` decimal(20, 2) NULL DEFAULT NULL COMMENT '巡检项值',
  PRIMARY KEY (`history_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1108 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for patrol_history_abnormal_item
-- ----------------------------
DROP TABLE IF EXISTS `patrol_history_abnormal_item`;
CREATE TABLE `patrol_history_abnormal_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `item_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `item_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `is_enable` tinyint(4) NOT NULL,
  `patrol_type` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for patrol_history_ctyun
-- ----------------------------
DROP TABLE IF EXISTS `patrol_history_ctyun`;
CREATE TABLE `patrol_history_ctyun`  (
  `history_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `patrol_plan_id` bigint(20) NOT NULL,
  `run_time` datetime NOT NULL,
  `task_id` bigint(20) NOT NULL,
  `is_enable` tinyint(4) NOT NULL,
  `task_name` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `app_type` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `description` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `history_finish_time` datetime NULL DEFAULT NULL,
  `history_status` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `creater` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `pool_name` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `xxl_log_id` bigint(20) NULL DEFAULT NULL,
  `historyId` bigint(20) NULL DEFAULT NULL,
  `is_running` tinyint(4) NULL DEFAULT NULL,
  `patrol_type` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `environment_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `environment_id` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`history_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 58 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for patrol_history_ctyun_device
-- ----------------------------
DROP TABLE IF EXISTS `patrol_history_ctyun_device`;
CREATE TABLE `patrol_history_ctyun_device`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `task_id` bigint(20) NULL DEFAULT NULL,
  `device_code` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `sn` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `mg_ip` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `vendor_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `pool_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL,
  `pool_id` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `ex_sys_id` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `city_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `province_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `res_pool_type_code` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `environment_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `environment_id` bigint(20) NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `sn`(`sn`, `task_id`) USING BTREE,
  INDEX `task_id`(`task_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 383 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for patrol_history_ctyun_result
-- ----------------------------
DROP TABLE IF EXISTS `patrol_history_ctyun_result`;
CREATE TABLE `patrol_history_ctyun_result`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sn` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `item_data` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `item_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `item_value` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `item_msg` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `item_rule` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `item_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `item_desc` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `task_id` bigint(20) NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `sn`(`sn`, `item_code`, `task_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7303 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for patrol_item
-- ----------------------------
DROP TABLE IF EXISTS `patrol_item`;
CREATE TABLE `patrol_item`  (
  `res_pool_id` bigint(20) NOT NULL COMMENT '资源池id，关联net_chain表',
  `patrol_item_id` bigint(50) NOT NULL COMMENT '巡检项id，与资源池id组成主键',
  `patrolType` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '巡检类型   SVR：服务器   NET：网络设备',
  `patrol_item_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '巡检项code，用于判断巡检逻辑',
  `patrol_item_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '巡检项名称',
  `warn_threshold` decimal(20, 2) NULL DEFAULT NULL COMMENT '告警阈值',
  `desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述，主要包括巡检项说明等',
  PRIMARY KEY (`res_pool_id`, `patrol_item_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for patrol_item_device_relation
-- ----------------------------
DROP TABLE IF EXISTS `patrol_item_device_relation`;
CREATE TABLE `patrol_item_device_relation`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `item_code` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `task_id` bigint(20) NULL DEFAULT NULL,
  `sn` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 540 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for patrol_plan
-- ----------------------------
DROP TABLE IF EXISTS `patrol_plan`;
CREATE TABLE `patrol_plan`  (
  `patrol_plan_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '计划id',
  `patrol_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '巡检名称',
  `environment_id` bigint(20) NULL DEFAULT NULL,
  `patrol_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '巡检类型   SVR：服务器   NET：网络设备',
  `target_list` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '目标列表   数组，界面勾选的，加入数组',
  `patrol_item` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '巡检项     数组，界面勾选的，加入数组',
  `patrol_sch_typ` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '巡检周期   ONE：单次     CYC：周期性',
  `crontab_express` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '周期性crontab表达式，单次时，此字段填执行时间字符串格式为 YYYY-MM-DD HH24:Mi:SS',
  `xxl_job_id` bigint(20) NULL DEFAULT NULL COMMENT 'xxl_job中的任务id',
  `xxl_job_status` tinyint(4) NULL DEFAULT 0 COMMENT 'xxl_job中的调度状态：0-停止，1-运行',
  `last_run_time` datetime NULL DEFAULT NULL COMMENT '最后一次执行时间',
  `create_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '最后一次更新时间',
  PRIMARY KEY (`patrol_plan_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 110 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for s_image
-- ----------------------------
DROP TABLE IF EXISTS `s_image`;
CREATE TABLE `s_image`  (
  `id` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `created_at` datetime NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT NULL,
  `deleted_at` datetime NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `image_type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `size` bigint(20) NULL DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `location` tinytext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `os_arch` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `hypervisor` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'kvm',
  `disk_format` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `container_format` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `checksum` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `owner` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `min_disk` int(11) NULL DEFAULT NULL,
  `min_ram` int(11) NULL DEFAULT NULL,
  `protected` tinyint(1) NULL DEFAULT NULL,
  `public` tinyint(1) NULL DEFAULT NULL,
  `fast_hash` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `oss_checksum` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `torrent_size` bigint(20) NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `visibility` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `resource_id` varchar(48) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `file_id` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_s_image_deleted_at`(`deleted_at`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for s_image_property
-- ----------------------------
DROP TABLE IF EXISTS `s_image_property`;
CREATE TABLE `s_image_property`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT NULL,
  `deleted_at` datetime NULL DEFAULT NULL,
  `image_id` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `value` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_s_image_property_deleted_at`(`deleted_at`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 349 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for s_sub_image
-- ----------------------------
DROP TABLE IF EXISTS `s_sub_image`;
CREATE TABLE `s_sub_image`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT NULL,
  `deleted_at` datetime NULL DEFAULT NULL,
  `image_id` varchar(36) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `format` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `location` tinytext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `size` bigint(20) NULL DEFAULT NULL,
  `checksum` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `fast_hash` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `oss_checksum` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_s_sub_image_deleted_at`(`deleted_at`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for server_statistics_day
-- ----------------------------
DROP TABLE IF EXISTS `server_statistics_day`;
CREATE TABLE `server_statistics_day`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ref_id` bigint(20) NOT NULL,
  `account_id` bigint(20) NOT NULL,
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `server_total` bigint(20) NOT NULL,
  `statistics_day` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ref_id_account_id_tenant_id_statistics_day`(`ref_id`, `account_id`, `tenant_id`, `statistics_day`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '实例日报表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for service_mgt_dirll_scence_rel
-- ----------------------------
DROP TABLE IF EXISTS `service_mgt_dirll_scence_rel`;
CREATE TABLE `service_mgt_dirll_scence_rel`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '演练场景关联ID',
  `scene_id` bigint(20) NOT NULL COMMENT '演练场景ID',
  `app_id` int(10) NOT NULL COMMENT '应用ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci COMMENT = '演练场景关联应用表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for service_mgt_drill_scene
-- ----------------------------
DROP TABLE IF EXISTS `service_mgt_drill_scene`;
CREATE TABLE `service_mgt_drill_scene`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '演练场景ID',
  `scene_name` varchar(60) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT '场景名称',
  `vdc_code` varchar(25) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL COMMENT '组织code',
  `tenant_id` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `send_notice` char(1) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT '0' COMMENT '是否发送通知：0否 1是',
  `
describe` varchar(500) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL COMMENT '描述',
  `config_content` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL COMMENT '配置内容',
  `is_template` char(1) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT '0' COMMENT '是否模板： 0否 1是',
  `quote_template_id` bigint(20) NULL DEFAULT NULL COMMENT '引用模板ID',
  `status` char(2) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT '1' COMMENT '状态： 0停用 1启用',
  `creator` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_at` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `logical_delete` char(1) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT '0' COMMENT '逻辑删除 0正常 1删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci COMMENT = '演练场景表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for service_resource_relation_template_category
-- ----------------------------
DROP TABLE IF EXISTS `service_resource_relation_template_category`;
CREATE TABLE `service_resource_relation_template_category`  (
  `res_temp_id` int(11) NOT NULL,
  `res_temp_category_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`res_temp_id`, `res_temp_category_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for service_resource_template
-- ----------------------------
DROP TABLE IF EXISTS `service_resource_template`;
CREATE TABLE `service_resource_template`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `tenant_id` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `vdc_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `visibility_scope` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `adapter_mode` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `icon` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `appId` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `creator` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_at` datetime NULL DEFAULT NULL,
  `update_at` datetime NULL DEFAULT NULL,
  `delete_at` bigint(19) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 71 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for service_resource_template_version
-- ----------------------------
DROP TABLE IF EXISTS `service_resource_template_version`;
CREATE TABLE `service_resource_template_version`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `temp_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `config_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `xml_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `version_status` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `temp_id` int(10) NULL DEFAULT NULL,
  `deployment_type` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `integr_url` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `appVersionId` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `creator` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_at` datetime NULL DEFAULT NULL,
  `update_at` datetime NULL DEFAULT NULL,
  `delete_at` bigint(19) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 78 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for service_runtime_app
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_app`;
CREATE TABLE `service_runtime_app`  (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT '应用运行时id',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '应用运行时名称',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '应用唯一编码',
  `tenant_id` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `vdc_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组织code',
  `visibility_scope` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `adapter_mode` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `icon` tinytext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '图标',
  `appId` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '发布应用市场ID',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述',
  `creator` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_at` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `delete_at` bigint(20) NULL DEFAULT NULL COMMENT '逻辑删除',
  `status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '状态：0-启用、1-停用',
  `approve_status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '审批状态：0-待审批 1-审批通过 2-审批不通过',
  `pic` varchar(60) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '应用负责人',
  `exp_date` datetime NULL DEFAULT NULL COMMENT '使用期限',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_code`(`code`, `delete_at`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 988 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for service_runtime_app_detection_status
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_app_detection_status`;
CREATE TABLE `service_runtime_app_detection_status`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '探测ID',
  `version_id` int(11) NOT NULL COMMENT '版本ID',
  `role_id` int(11) NOT NULL COMMENT '角色ID',
  `node_ip` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '节点IP',
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '探测名称',
  `status` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '运行状态: init-初始化、start-运行、stop-停止、error-错误',
  `interval_val` int(11) NULL DEFAULT NULL COMMENT '间隔（秒）',
  `exec_cmd` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '执行脚本',
  `error_reason` varchar(1200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '失败原因',
  `create_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_at` datetime NULL DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_service_runtime_app_detection_vrn`(`version_id`, `role_id`, `node_ip`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'APP运行状态探测表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for service_runtime_app_publish
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_app_publish`;
CREATE TABLE `service_runtime_app_publish`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `version_id` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '版本ID',
  `app_version_id` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '应用管理版本ID',
  `old_app_version_id` varchar(11) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '旧应用管理版本ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '发布名称',
  `tenant_id` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `vdc_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '组织code',
  `status` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '发布状态',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '描述',
  `creator` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_at` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `delete_at` bigint(20) NULL DEFAULT NULL COMMENT '逻辑删除',
  `time` int(11) NULL DEFAULT NULL COMMENT '耗时',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 191 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '应用发布表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for service_runtime_app_publish_batch
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_app_publish_batch`;
CREATE TABLE `service_runtime_app_publish_batch`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `pub_id` varchar(11) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '发布ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '角色名称',
  `seq` bigint(20) NULL DEFAULT NULL COMMENT '当前批次',
  `batch` bigint(20) NULL DEFAULT NULL COMMENT '总批次',
  `time` bigint(20) NULL DEFAULT NULL COMMENT '耗时',
  `content` varchar(5000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '日志内容',
  `status` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '执行状态1-运行;2-部署中;3-停止;4-失败',
  `execute_status` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '执行状态 0-已执行，1-未执行',
  `pods` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '批次内Pod',
  `creator` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `create_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_at` datetime NULL DEFAULT NULL,
  `delete_at` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 289 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '应用发布批次表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for service_runtime_app_publish_mode
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_app_publish_mode`;
CREATE TABLE `service_runtime_app_publish_mode`  (
  `role_id` int(11) NOT NULL COMMENT '角色ID',
  `deployment_mode` int(4) NULL DEFAULT NULL COMMENT '部署暂停模式',
  `create_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_at` datetime NULL DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色部署暂停模式表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for service_runtime_app_publish_pod
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_app_publish_pod`;
CREATE TABLE `service_runtime_app_publish_pod`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `batch_id` varchar(11) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '批次Id',
  `seq` int(11) NULL DEFAULT NULL COMMENT '批次',
  `pod_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Pod名称',
  `status` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '执行状态1-运行;2-部署中;3-停止;4-失败',
  `time` bigint(20) NULL DEFAULT NULL COMMENT '耗时',
  `content` varchar(5000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '日志内容',
  `create_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `pod_ip` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'PodIp',
  `host_ip` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'HostIp',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 424 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '应用发布批次Pod表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for service_runtime_app_publish_version
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_app_publish_version`;
CREATE TABLE `service_runtime_app_publish_version`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `temp_data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `config_json` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `xml_data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `version_status` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `runtime_app_id` int(11) NULL DEFAULT NULL,
  `deployment_type` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `integr_url` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `appVersionId` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `process_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '流程图ID',
  `instance_size` int(11) NULL DEFAULT NULL,
  `deployment_date` datetime NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `creator` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `create_at` datetime NULL DEFAULT NULL,
  `update_at` datetime NULL DEFAULT NULL,
  `delete_at` bigint(20) NULL DEFAULT NULL,
  `across_the_pool` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否跨环境',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 186 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '应用发布版本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for service_runtime_app_role
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_app_role`;
CREATE TABLE `service_runtime_app_role`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `version_id` int(11) NOT NULL,
  `cpu` int(11) NULL DEFAULT NULL,
  `gpu` int(11) NULL DEFAULT NULL,
  `memory` int(11) NULL DEFAULT NULL,
  `replica` int(11) NULL DEFAULT NULL,
  `kind` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `storage_size` int(11) NULL DEFAULT NULL,
  `instance_size` int(11) NULL DEFAULT NULL,
  `env` tinytext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `status` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `res_pool_id` int(11) NULL DEFAULT NULL,
  `app_environment_id` bigint(20) NULL DEFAULT NULL,
  `deployment_date` datetime NULL DEFAULT NULL,
  `deployment_type` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `parent_id` int(11) NULL DEFAULT NULL COMMENT '根id,为0表示顶层',
  `has_leaf` tinyint(2) NULL DEFAULT NULL COMMENT '判断是否有叶子,1表示有叶子,0表示无叶子',
  `publish_mode` int(4) NULL DEFAULT NULL,
  `deployment_mode` int(4) NULL DEFAULT NULL,
  `instance_update_strategy` int(4) NULL DEFAULT NULL,
  `batch_number` int(4) NULL DEFAULT NULL,
  `component_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '前端组件对应的唯一ID,',
  `ref_role_id` int(11) NULL DEFAULT NULL COMMENT '引用角色ID',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序字段',
  `creator` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_at` datetime NULL DEFAULT NULL,
  `update_at` datetime NULL DEFAULT NULL,
  `delete_at` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3354 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for service_runtime_app_role_config
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_app_role_config`;
CREATE TABLE `service_runtime_app_role_config`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NULL DEFAULT NULL COMMENT 'role_id',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'config文件名称',
  `file_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'config对应文件内容',
  `version_id` int(11) NULL DEFAULT NULL,
  `is_system` int(2) NULL DEFAULT NULL COMMENT '用户配置文件为0,系统为1',
  `create_at` datetime NULL DEFAULT NULL,
  `update_at` datetime NULL DEFAULT NULL,
  `delete_at` bigint(20) NULL DEFAULT NULL,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'cm路径',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_role_id`(`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15379 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for service_runtime_app_version
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_app_version`;
CREATE TABLE `service_runtime_app_version`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `temp_data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `config_json` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `xml_data` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `version_status` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `runtime_app_id` int(11) NULL DEFAULT NULL,
  `deployment_type` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `integr_url` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `appVersionId` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `process_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '流程图ID',
  `instance_size` int(11) NULL DEFAULT NULL,
  `deployment_date` datetime NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `creator` varchar(25) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `create_at` datetime NULL DEFAULT NULL,
  `update_at` datetime NULL DEFAULT NULL,
  `delete_at` bigint(20) NULL DEFAULT NULL,
  `across_the_pool` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '是否跨环境',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1247 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for service_runtime_environment
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_environment`;
CREATE TABLE `service_runtime_environment`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `category` int(5) NULL DEFAULT NULL,
  `vdc_code` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `res_pool_id` bigint(25) NULL DEFAULT NULL,
  `tenant_id` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `labels` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `namespaces` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `publish_mode` int(4) NULL DEFAULT NULL,
  `deployment_mode` int(4) NULL DEFAULT NULL,
  `instance_update_strategy` int(4) NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `creator` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_at` datetime NULL DEFAULT NULL,
  `update_at` datetime NULL DEFAULT NULL,
  `delete_at` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1677219990053707779 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for service_runtime_template_category_rel
-- ----------------------------
DROP TABLE IF EXISTS `service_runtime_template_category_rel`;
CREATE TABLE `service_runtime_template_category_rel`  (
  `service_runtime_id` int(11) NOT NULL,
  `res_temp_category_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`service_runtime_id`, `res_temp_category_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_account_sync_item
-- ----------------------------
DROP TABLE IF EXISTS `sys_account_sync_item`;
CREATE TABLE `sys_account_sync_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `res_id` int(11) NOT NULL,
  `batch_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '同步批次号',
  `account_id` bigint(20) NOT NULL,
  `ref_id` bigint(20) NOT NULL,
  `sync_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `sync_status` int(11) NOT NULL COMMENT '(10:同步成功  -10:同步失败)',
  `err_reason` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `item_count` int(11) NULL DEFAULT 0 COMMENT '同步数量',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `task_id_batch_code_ref_id`(`res_id`, `batch_code`, `ref_id`) USING BTREE,
  INDEX `task_id`(`res_id`) USING BTREE,
  INDEX `account_id`(`account_id`) USING BTREE,
  INDEX `ref_id`(`ref_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '账户同步明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_azone
-- ----------------------------
DROP TABLE IF EXISTS `sys_azone`;
CREATE TABLE `sys_azone`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `region_code` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `out_region_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '外部region',
  `res_type_id` int(11) NULL DEFAULT NULL COMMENT '资源类型',
  `tenant_id` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `out_region_code_res_type_id`(`out_region_code`, `res_type_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_billing_item
-- ----------------------------
DROP TABLE IF EXISTS `sys_billing_item`;
CREATE TABLE `sys_billing_item`  (
  `billing_item_id` int(11) NOT NULL COMMENT '计费项ID',
  `billing_item_code` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '计费项编码，唯一标识',
  `billing_item_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '计费项名称',
  `delete_at` tinyint(20) NULL DEFAULT NULL COMMENT '逻辑删除',
  `tenant_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '租户id',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建者',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '更新者',
  PRIMARY KEY (`billing_item_id`) USING BTREE,
  UNIQUE INDEX `billing_item_code`(`billing_item_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '计费项表，用于存储不同类型的计费项信息' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_billing_rules
-- ----------------------------
DROP TABLE IF EXISTS `sys_billing_rules`;
CREATE TABLE `sys_billing_rules`  (
  `rule_id` int(11) NOT NULL COMMENT '计费规则ID',
  `rule_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '计费规则名称',
  `billing_item_id` int(11) NULL DEFAULT NULL COMMENT '关联的计费项ID',
  `billing_item_code` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '关联的计费项编码',
  `measurement_unit` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '计量单位',
  `measurement_value` decimal(10, 2) NULL DEFAULT NULL COMMENT '计量值',
  `rate_hourly` decimal(10, 2) NULL DEFAULT NULL COMMENT '按小时计费费率',
  `rate_monthly` decimal(10, 2) NULL DEFAULT NULL COMMENT '按月计费费率',
  `rate_yearly` decimal(10, 2) NULL DEFAULT NULL COMMENT '按年计费费率',
  `object_type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '规则适用的对象类型，为空表示通用，0-按私有云类型计费1-按私有云实例计费',
  `object_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '规则适用的对象ID，如果是通用规则，可以为空；object_type 为0 该值为res_pool_type_code,object_type为1 该值为资源池实例id',
  `delete_at` tinyint(20) NULL DEFAULT NULL COMMENT '逻辑删除',
  `tenant_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '租户id',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_by` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建者',
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_by` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '更新者',
  PRIMARY KEY (`rule_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '计费规则表，定义不同计费规则和关联的计费项信息' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_cloud_resource_apply
-- ----------------------------
DROP TABLE IF EXISTS `sys_cloud_resource_apply`;
CREATE TABLE `sys_cloud_resource_apply`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `res_pool_type_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源池类型名称',
  `res_pool_id` int(11) NOT NULL COMMENT '资源池ID',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `obj_id` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `obj_type` int(11) NOT NULL COMMENT '1:组织  2:项目',
  `apply_count` int(11) NOT NULL,
  `apply_user_id` bigint(20) NULL DEFAULT NULL,
  `apply_time` datetime NULL DEFAULT NULL,
  `apply_status` int(11) NULL DEFAULT NULL COMMENT '申请状态(0:初始   5:就绪中 8:处理中  10:处理完成   -10:处理失败)',
  `err_reason` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '失败原因',
  `apply_param` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '云参数',
  `order_id` bigint(20) NULL DEFAULT NULL COMMENT '订单ID',
  `res_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '云资源类型，server,keypair等',
  `service_id` bigint(20) NULL DEFAULT NULL COMMENT '服务ID',
  `environment_id` bigint(20) NULL DEFAULT NULL COMMENT 'envId',
  `resource_original_id` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '多个云资源ID，以逗号分隔',
  `ext_param` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '扩展参数',
  `event_code` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '事件编码',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ref_id`(`res_pool_id`) USING BTREE,
  INDEX `transport_type`(`res_pool_type_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1990725706345635843 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '云资源申请记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_cloud_summ_day
-- ----------------------------
DROP TABLE IF EXISTS `sys_cloud_summ_day`;
CREATE TABLE `sys_cloud_summ_day`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `syn_time` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '同步时间',
  `res_pool_id` int(11) NULL DEFAULT NULL COMMENT 'ref_id',
  `res_pool_type_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `environment_id` int(11) NULL DEFAULT NULL COMMENT '账户ID',
  `cloud_type` int(11) NULL DEFAULT NULL,
  `tenant_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `obj_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `obj_type` int(11) NULL DEFAULT NULL COMMENT '1组织 2项目',
  `only_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `cloud_count` int(11) NULL DEFAULT 0 COMMENT '云主机总数',
  `run_count` int(11) NULL DEFAULT 0 COMMENT '运行主机总数',
  `stop_count` int(11) NULL DEFAULT 0 COMMENT '停止主机总数',
  `abnormal_count` int(11) NULL DEFAULT 0 COMMENT '异常主机总数',
  `other_count` int(11) NULL DEFAULT 0 COMMENT '其他主机总数',
  `about_expire_count` int(11) NULL DEFAULT 0 COMMENT '即将过期主机总数',
  `expire_count` int(11) NULL DEFAULT 0 COMMENT '过期主机总数',
  `cpu_count` int(11) NULL DEFAULT 0 COMMENT 'CPU总核数',
  `cpu_usage` decimal(4, 2) NULL DEFAULT 0.00 COMMENT 'CPU使用率',
  `cpu_distribution` decimal(4, 2) NULL DEFAULT 0.00 COMMENT 'CPU分配率',
  `mem_count` bigint(64) NULL DEFAULT 0 COMMENT '内存总大小',
  `mem_usage` decimal(4, 2) NULL DEFAULT 0.00 COMMENT '内存使用率',
  `mem_distribution` decimal(4, 2) NULL DEFAULT 0.00 COMMENT '内存分配率',
  `snapshot_count` int(11) NULL DEFAULT 0 COMMENT '快照',
  `security_group_count` int(11) NULL DEFAULT 0 COMMENT '安全组',
  `rds_count` int(11) NULL DEFAULT 0 COMMENT 'RDS',
  `lvs_count` int(11) NULL DEFAULT 0 COMMENT '负载均衡',
  `cache_count` int(11) NULL DEFAULT 0 COMMENT '缓存服务',
  `message_count` int(11) NULL DEFAULT 0 COMMENT '消息服务',
  `disk_count` bigint(11) NULL DEFAULT 0 COMMENT '硬盘总个数',
  `disk_mounted_count` bigint(11) NULL DEFAULT 0 COMMENT '硬盘挂载个数,IN-USE使用中',
  `disk_unmounted_count` bigint(11) NULL DEFAULT 0 COMMENT '硬盘未挂载数,AVAILABLE，可用',
  `disk_error_count` bigint(11) NULL DEFAULT 0 COMMENT '硬盘错误数',
  `disk_other_count` bigint(11) NULL DEFAULT 0 COMMENT '硬盘其他数',
  `disk_sum` bigint(64) NULL DEFAULT 0 COMMENT '硬盘总容量',
  `disk_mounted_sum` bigint(64) NULL DEFAULT 0 COMMENT '挂载硬盘容量',
  `disk_unmounted_sum` bigint(64) NULL DEFAULT 0 COMMENT '未挂载硬盘容量',
  `disk_error_sum` bigint(64) NULL DEFAULT 0 COMMENT '硬盘错误容量',
  `disk_other_sum` bigint(64) NULL DEFAULT 0 COMMENT '硬盘其他容量',
  `disk_expire_sum` bigint(64) NULL DEFAULT 0 COMMENT '过期硬盘容量',
  `disk_about_expire_sum` bigint(11) NULL DEFAULT 0 COMMENT '即将过期硬盘容量',
  `disk_usage` decimal(4, 2) NULL DEFAULT 0.00 COMMENT '存储使用率',
  `disk_distribution` decimal(4, 2) NULL DEFAULT 0.00 COMMENT '存储分配率',
  `network_count` int(11) NULL DEFAULT 0 COMMENT '网络总个数',
  `network_usage` decimal(4, 2) NULL DEFAULT 0.00 COMMENT '网络使用率',
  `subnet_count` int(11) NULL DEFAULT 0 COMMENT '子网个数',
  `file_disk_count` int(11) NULL DEFAULT 0 COMMENT '文件存储',
  `file_mounted_count` int(11) NULL DEFAULT 0 COMMENT '文件挂载',
  `file_unmounted_count` int(11) NULL DEFAULT 0 COMMENT '文件未挂载',
  `elastic_ip_count` int(11) NULL DEFAULT 0 COMMENT '弹性IP',
  `ip_mounted_count` int(11) NULL DEFAULT 0 COMMENT 'ip挂载',
  `ip_unmounted_count` int(11) NULL DEFAULT 0 COMMENT 'ip未挂载',
  `ip_error_count` int(11) NULL DEFAULT 0 COMMENT 'IP错误数',
  `ip_about_expire_count` int(11) NULL DEFAULT 0 COMMENT '即将过期ip总数',
  `ip_expire_count` int(11) NULL DEFAULT 0 COMMENT '过期ip总数',
  `ip_other_count` int(11) NULL DEFAULT 0 COMMENT 'IP其他状态',
  `object_disk_count` int(11) NULL DEFAULT 0 COMMENT '对象存储',
  `object_mounted_count` int(11) NULL DEFAULT 0 COMMENT '对象挂载',
  `object_unmounted_count` int(11) NULL DEFAULT 0 COMMENT '对象未挂载',
  `is_public` int(1) UNSIGNED ZEROFILL NULL DEFAULT 1 COMMENT '1: 私有资源 2: 共享资源',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3409 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '可视化表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_cost_detail
-- ----------------------------
DROP TABLE IF EXISTS `sys_cost_detail`;
CREATE TABLE `sys_cost_detail`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sys_original_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源ID',
  `pay_type` int(11) NULL DEFAULT NULL COMMENT '付费类型1:预付费,2:后付费',
  `vdc_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '组织编码',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `create_user` bigint(20) NULL DEFAULT NULL,
  `update_user` bigint(20) NULL DEFAULT NULL,
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `availability_zone` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '可用区',
  `configuration` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '配置',
  `res_type_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源类型编码',
  `res_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源编码',
  `account_id` bigint(20) NULL DEFAULT NULL COMMENT '账户ID',
  `ref_id` bigint(20) NULL DEFAULT NULL,
  `fee` bigint(20) NULL DEFAULT NULL COMMENT '费用',
  `bill_type` int(11) NULL DEFAULT NULL COMMENT '账单类型',
  `product_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '产品ID',
  `product_name` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '产品名字',
  `trade_id` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '交易ID',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `query_param` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '本次查询传递的参数',
  `currency` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '货币单位代码:CNY:人民币USD:美元',
  `charge_mode` int(11) NULL DEFAULT NULL COMMENT '1 : 包周期;3: 按需。10: 预留实例',
  `resource_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源名称',
  `amount` bigint(20) NULL DEFAULT NULL COMMENT '消费金额',
  `discount_amount` bigint(20) NULL DEFAULT NULL COMMENT '折扣金额',
  `cash_amount` bigint(20) NULL DEFAULT NULL COMMENT '现金支付金额',
  `credit_amount` bigint(20) NULL DEFAULT NULL COMMENT '信用额度支付金额',
  `coupon_amount` bigint(20) NULL DEFAULT NULL COMMENT '代金券支付金额',
  `flexipurchase_coupon_amount` bigint(20) NULL DEFAULT NULL COMMENT '现金券支付金额',
  `stored_card_amount` bigint(20) NULL DEFAULT NULL COMMENT '储值卡支付金额',
  `bonus_amount` bigint(20) NULL DEFAULT NULL COMMENT '奖励金支付金额(用于现网未清干净的奖励金)',
  `debt_amount` bigint(20) NULL DEFAULT NULL COMMENT '欠费金额',
  `adjustment_amount` bigint(20) NULL DEFAULT NULL COMMENT '欠费核销金额',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `IDX_TRADE_ID`(`trade_id`, `product_id`, `tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_cost_summ_day
-- ----------------------------
DROP TABLE IF EXISTS `sys_cost_summ_day`;
CREATE TABLE `sys_cost_summ_day`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `vdc_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '组织编码',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `res_pool_type_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源类型编码',
  `res_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源编码',
  `environment_id` bigint(20) NULL DEFAULT NULL COMMENT '账户ID',
  `res_pool_id` bigint(20) NULL DEFAULT NULL,
  `fee` bigint(20) NULL DEFAULT NULL COMMENT '费用',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `syn_date` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '同步时间',
  `charge_mode` int(11) NULL DEFAULT NULL,
  `sys_original_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源ID',
  `syn_time` date NULL DEFAULT NULL COMMENT '归属时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `NewIndex1`(`syn_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_dict_area
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_area`;
CREATE TABLE `sys_dict_area`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `province` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `county` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `area_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `lng` float(12, 6) NULL DEFAULT NULL,
  `lat` float(12, 6) NULL DEFAULT NULL,
  `lev` int(3) NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `alias` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_area_code`(`area_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '系统区域字典表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_energy_efficiency_statistics_vm_day
-- ----------------------------
DROP TABLE IF EXISTS `sys_energy_efficiency_statistics_vm_day`;
CREATE TABLE `sys_energy_efficiency_statistics_vm_day`  (
  `statistic_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `organization_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组织编码',
  `organization_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组织名称',
  `parent_organization_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '上层组织编码',
  `resource_id` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源实例ID',
  `resource_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '资源名称',
  `sys_original_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '虚拟机外部id',
  `resource_pool_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '资源池类型',
  `res_code` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源code',
  `res_pool_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源池ID',
  `environment_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '账号ID',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户',
  `cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '成本',
  `energy_efficiency` decimal(10, 2) NULL DEFAULT NULL COMMENT '综合能效',
  `efficiency_ratio` decimal(10, 2) NULL DEFAULT NULL COMMENT '能效比',
  `vcpu` decimal(10, 2) NULL DEFAULT NULL COMMENT '虚拟CPU数量',
  `memory` decimal(10, 2) NULL DEFAULT NULL COMMENT '内存大小',
  `disk` decimal(10, 2) NULL DEFAULT NULL COMMENT '磁盘大小',
  `cpu_utilization` decimal(5, 2) NULL DEFAULT NULL COMMENT 'CPU利用率',
  `memory_utilization` decimal(5, 2) NULL DEFAULT NULL COMMENT '内存使用率',
  `disk_utilization` decimal(5, 2) NULL DEFAULT NULL COMMENT '磁盘使用率',
  `vm_count` int(11) NULL DEFAULT NULL COMMENT '虚拟机数量',
  `actual_cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '实际成本',
  `effective_cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '有效成本',
  `days` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '统计周期（天）',
  `statistics_date` datetime NULL DEFAULT NULL COMMENT '统计日期',
  PRIMARY KEY (`statistic_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2796234 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '虚拟机资源能效统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_environment
-- ----------------------------
DROP TABLE IF EXISTS `sys_environment`;
CREATE TABLE `sys_environment`  (
  `environment_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `show_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '账号显示名称',
  `res_pool_type_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源池类型编码',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `auth_type` int(3) NULL DEFAULT NULL COMMENT '认证类型  1: userName+password     2:AccessToken+Secret Key',
  `auth_param` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '认证参数JSON',
  `res_sync_interval` int(11) UNSIGNED NULL DEFAULT NULL COMMENT '资源同步周期(单位：分钟)',
  `monitor_collect_interval` int(11) UNSIGNED NULL DEFAULT NULL COMMENT '监控采集间隔(单位: 秒)',
  `alarm_collect_interval` int(11) UNSIGNED NULL DEFAULT NULL COMMENT '告警采集频率(单位: 秒)',
  `add_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `account_amount` bigint(20) NULL DEFAULT 0 COMMENT '账户余额,单位:分',
  `debt_amount` bigint(20) NULL DEFAULT 0 COMMENT '欠费金额,单位:分',
  `account_update_time` timestamp NULL DEFAULT NULL COMMENT '账户变更时间',
  `init_status` int(3) NULL DEFAULT 0 COMMENT '0:初始   5:正在初始化   10:初始化完成',
  `fingerprint_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '指纹码(用于验证一个租户下只能有一个同管理账号存在)',
  `kubeedge_status` int(3) NULL DEFAULT 0 COMMENT '0:未部署云端节点  1：已经部署云端节点',
  PRIMARY KEY (`environment_id`) USING BTREE,
  UNIQUE INDEX `tenant_id_fingerprint_code`(`tenant_id`, `fingerprint_code`) USING BTREE,
  INDEX `res_type_id`(`res_pool_type_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 55671 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '环境信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_environment_20241008
-- ----------------------------
DROP TABLE IF EXISTS `sys_environment_20241008`;
CREATE TABLE `sys_environment_20241008`  (
  `environment_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `show_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '账号显示名称',
  `res_pool_type_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源池类型编码',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `auth_type` int(3) NULL DEFAULT NULL COMMENT '认证类型  1: userName+password     2:AccessToken+Secret Key',
  `auth_param` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '认证参数JSON',
  `res_sync_interval` int(11) UNSIGNED NULL DEFAULT NULL COMMENT '资源同步周期(单位：分钟)',
  `monitor_collect_interval` int(11) UNSIGNED NULL DEFAULT NULL COMMENT '监控采集间隔(单位: 秒)',
  `alarm_collect_interval` int(11) UNSIGNED NULL DEFAULT NULL COMMENT '告警采集频率(单位: 秒)',
  `add_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `account_amount` bigint(20) NULL DEFAULT 0 COMMENT '账户余额,单位:分',
  `debt_amount` bigint(20) NULL DEFAULT 0 COMMENT '欠费金额,单位:分',
  `account_update_time` timestamp NULL DEFAULT NULL COMMENT '账户变更时间',
  `init_status` int(3) NULL DEFAULT 0 COMMENT '0:初始   5:正在初始化   10:初始化完成',
  `fingerprint_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '指纹码(用于验证一个租户下只能有一个同管理账号存在)',
  `kubeedge_status` int(3) NULL DEFAULT 0 COMMENT '0:未部署云端节点  1：已经部署云端节点',
  PRIMARY KEY (`environment_id`) USING BTREE,
  UNIQUE INDEX `tenant_id_fingerprint_code`(`tenant_id`, `fingerprint_code`) USING BTREE,
  INDEX `res_type_id`(`res_pool_type_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 55634 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '环境信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_group
-- ----------------------------
DROP TABLE IF EXISTS `sys_group`;
CREATE TABLE `sys_group`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '分组名称',
  `vdc_code` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '区域code',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NOT NULL COMMENT '更新时间',
  `update_user` bigint(20) NULL DEFAULT NULL COMMENT '更新人',
  `create_user` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `tenant_id` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `ascription_target_type` int(11) NULL DEFAULT NULL COMMENT '归属目标类型',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'pc机分组' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_group_pc
-- ----------------------------
DROP TABLE IF EXISTS `sys_group_pc`;
CREATE TABLE `sys_group_pc`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` bigint(20) NOT NULL,
  `pc_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `create_user` bigint(20) NULL DEFAULT NULL,
  `update_user` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_image
-- ----------------------------
DROP TABLE IF EXISTS `sys_image`;
CREATE TABLE `sys_image`  (
  `id` int(11) NOT NULL,
  `region_code` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `vdc_code` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'vdc编码',
  `res_type` int(11) NULL DEFAULT NULL COMMENT '资源类型',
  `tenant_id` int(11) NULL DEFAULT NULL COMMENT '外部镜像code',
  `arch` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '镜像体系结构',
  `image_size` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `keystone_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_job_task
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_task`;
CREATE TABLE `sys_job_task`  (
  `job_task_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_task_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '任务名称',
  `job_task_content` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '任务流程内容',
  `job_execute_type` int(1) NULL DEFAULT NULL COMMENT '执行方式  0: 单次执行   1:周期执行',
  `job_execute_content` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '执行内容',
  `job_task_status` int(3) NULL DEFAULT NULL COMMENT '任务状态  0:未发布   10:已发布',
  `job_task_desc` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '任务描述',
  `job_task_param` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '任务全局参数(json)',
  `last_run_time` datetime NULL DEFAULT NULL COMMENT '最后运行时间',
  `next_run_time` datetime NULL DEFAULT NULL COMMENT '下次执行时间',
  `can_retry` int(1) NULL DEFAULT NULL COMMENT '是否支持失败重试\n0:否  1::是',
  `max_retry_times` int(11) NULL DEFAULT NULL COMMENT '最大重试次数',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `create_user` bigint(20) NULL DEFAULT NULL,
  `update_user` bigint(20) NULL DEFAULT NULL,
  `is_deleted` int(11) NULL DEFAULT 0 COMMENT '是否删除\n1:是\n0：否',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `status` int(2) NULL DEFAULT 0 COMMENT '状态',
  PRIMARY KEY (`job_task_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '任务编排定义表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_job_task_item
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_task_item`;
CREATE TABLE `sys_job_task_item`  (
  `task_item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `job_task_id` bigint(20) NULL DEFAULT NULL COMMENT '任务ID',
  `execute_target_id` bigint(20) NULL DEFAULT NULL COMMENT '执行目标ID',
  `execute_time` datetime NULL DEFAULT NULL COMMENT '执行时间',
  `execute_status_code` int(1) NULL DEFAULT NULL COMMENT '执行结果状态',
  `error_log` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '错误日志',
  `execute_duration` bigint(20) NULL DEFAULT NULL COMMENT '执行时长(毫秒)',
  `execute_content_snapshots` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '执行内容快照',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `create_user` bigint(20) NULL DEFAULT NULL,
  `update_user` bigint(20) NULL DEFAULT NULL,
  `is_deleted` int(11) NULL DEFAULT 0 COMMENT '是否删除\n1：是\n0：否',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  PRIMARY KEY (`task_item_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '定时任务执行历史' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_message_queue
-- ----------------------------
DROP TABLE IF EXISTS `sys_message_queue`;
CREATE TABLE `sys_message_queue`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `msg_no` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `message` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '异步消息表，用于消息幂等' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_meters_metric_bill
-- ----------------------------
DROP TABLE IF EXISTS `sys_meters_metric_bill`;
CREATE TABLE `sys_meters_metric_bill`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `res_code` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源code',
  `res_pool_type_code` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源类型code',
  `resource_id` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源实例ID',
  `resource_spec_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源规格编码',
  `resource_spec_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源规格名称',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户',
  `res_pool_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源池ID',
  `environment_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '账号ID',
  `vdc_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户组织机构',
  `begin_time` bigint(20) NULL DEFAULT NULL COMMENT '该条记录的统计周期的开始时间',
  `end_time` bigint(20) NULL DEFAULT NULL COMMENT '该条记录的统计周期的结束时间',
  `accumulate_factor_name` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '累积因子名:0：天（时长） 1：元（货币）2：角（货币） 3：分（货币）4：小时（时长） 5：分钟（时长） 6：秒（时长） 7：EB（流量）8：PB（流量）9：TB（流量）10：GB（流量）11：MB（流量）12：KB（流量）13：Byte（流量）14：个(次)（数量）15：Mbps（流量）16：Byte（容量）17：GB（容量）18：KLOC（行数）19：年（周期）20：月（周期）21：MB（容量）22：赫兹（频率）23：核（数量）24：天（周期）25：小时（周期）30：个数（个数）31：千次（数量）32：百万次（数量）33：十亿次（数量）34：bps（带宽速率）35：kbps（带宽速率）36：Mbps（带宽速率）37：Gbps（带宽速率）38：Tbps（带宽速率）39：GB-秒（容量时长）40：次（数量）41：个（数量）42：千个（数量）43：张（数量）44：千张（数量）45：每秒查询率（查询速率）46：人/天（数量）47：TB（容量） 48：PB（容量）',
  `accumulate_factor_value` decimal(20, 2) NULL DEFAULT NULL COMMENT '累积因子值',
  `syn_date` datetime NULL DEFAULT NULL,
  `bill_type` int(11) NULL DEFAULT NULL COMMENT '|参数名称:账单类型。1:消费-新购2:消费-续订3:消费-变更4:退款-退订5:消费-使用8:消费-自动续订9:调账-补偿12:消费-按时计费13:消费-退订手续费14:消费-服务支持计划月末扣费16:调账-扣费| |参数的约束及描述:账单类型。1:消费-新购2:消费-续订3:消费-变更4:退款-退订5:消费-使用8:消费-自动续订9:调账-补偿12:消费-按时计费13:消费-退订手续费14:消费-服务支持计划月末扣费16:调账-扣费|',
  `trade_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '订单ID或交易ID，扣费维度的唯一标识。',
  `sys_original_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3702 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_notify_message
-- ----------------------------
DROP TABLE IF EXISTS `sys_notify_message`;
CREATE TABLE `sys_notify_message`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '租户ID',
  `user_id` bigint(64) NOT NULL COMMENT '通知到人',
  `message_title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '消息通知标题',
  `message_notify_time` datetime NULL DEFAULT NULL COMMENT '消息通知时间',
  `message_type` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '消息类型',
  `message_status` tinyint(2) NULL DEFAULT NULL COMMENT '消息状态 1未读 2已读',
  `message_read_time` datetime NULL DEFAULT NULL COMMENT '消息第一次读的时间',
  `resource_origin` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '消息来源标识',
  `resource_key` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '消息关联外键标识',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_os_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_os_type`;
CREATE TABLE `sys_os_type`  (
  `os_type_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '类型ID',
  `type_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '操作系统名称',
  `logo` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '操作系统Logo',
  `byte_size` varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '操作系统位数:32,64',
  `architecture` bigint(20) NULL DEFAULT NULL COMMENT '1:x86,2:arm',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `create_user` bigint(20) NULL DEFAULT NULL COMMENT '创建者',
  `update_user` bigint(20) NULL DEFAULT NULL COMMENT '更新者',
  `is_deleted` int(11) NULL DEFAULT 0 COMMENT '是否删除,1:是,0:否',
  `status` int(11) NULL DEFAULT 0 COMMENT '状态,0正常',
  PRIMARY KEY (`os_type_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '操作系统类型' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_pc_command
-- ----------------------------
DROP TABLE IF EXISTS `sys_pc_command`;
CREATE TABLE `sys_pc_command`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ip` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'ip',
  `command` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '指令码',
  `command_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '指令编码',
  `command_param` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '指令参数',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `status` int(11) NULL DEFAULT NULL COMMENT '指令状态，1：初始状态，2：下发成功，3：执行成功，4：执行失败',
  `resource_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源ID(PC机ID)',
  `tenant_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '指令创建者',
  `command_result` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '指令执行结果',
  `update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_res_stat`(`resource_id`, `status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38554 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_pc_event
-- ----------------------------
DROP TABLE IF EXISTS `sys_pc_event`;
CREATE TABLE `sys_pc_event`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_user` bigint(20) NOT NULL COMMENT '操作人',
  `event_code` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '事件编码',
  `event_status` int(11) NOT NULL COMMENT '事件状态',
  `event_time` datetime NOT NULL COMMENT '事件时间',
  `command_id` bigint(20) NULL DEFAULT NULL COMMENT '命令ID',
  `resource_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_pc_event_copy1
-- ----------------------------
DROP TABLE IF EXISTS `sys_pc_event_copy1`;
CREATE TABLE `sys_pc_event_copy1`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_user` bigint(20) NOT NULL COMMENT '操作人',
  `event_code` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '事件编码',
  `event_status` int(11) NOT NULL COMMENT '事件状态',
  `event_time` datetime NOT NULL COMMENT '事件时间',
  `command_id` bigint(20) NULL DEFAULT NULL COMMENT '命令ID',
  `resource_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_project
-- ----------------------------
DROP TABLE IF EXISTS `sys_project`;
CREATE TABLE `sys_project`  (
  `project_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `project_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '项目名称',
  `project_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `vdc_code` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '组织编码',
  `project_status` tinyint(4) NULL DEFAULT NULL COMMENT '项目状态(0: 失效    1:正常)',
  `project_desc` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '项目描述',
  `crt_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `crt_user_id` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `last_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `last_user_id` bigint(20) NULL DEFAULT NULL COMMENT '最后修改人',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `project_version` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '当前版本',
  `leader` bigint(20) NULL DEFAULT NULL COMMENT '项目负责人',
  `quota_type` int(11) NULL DEFAULT NULL COMMENT '1:有配额，2：没有配额',
  `is_deleted` int(11) NULL DEFAULT 0 COMMENT '是否删除',
  `type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'org',
  `expand` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT 'cube-studio:项目拓展字段',
  PRIMARY KEY (`project_id`) USING BTREE,
  UNIQUE INDEX `project_code`(`project_code`) USING BTREE,
  INDEX `vdc_code`(`vdc_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 136 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_project_20240830
-- ----------------------------
DROP TABLE IF EXISTS `sys_project_20240830`;
CREATE TABLE `sys_project_20240830`  (
  `project_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `project_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '项目名称',
  `project_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `vdc_code` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '组织编码',
  `project_status` tinyint(4) NULL DEFAULT NULL COMMENT '项目状态(0: 失效    1:正常)',
  `project_desc` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '项目描述',
  `crt_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `crt_user_id` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `last_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `last_user_id` bigint(20) NULL DEFAULT NULL COMMENT '最后修改人',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `project_version` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '当前版本',
  `leader` bigint(20) NULL DEFAULT NULL COMMENT '项目负责人',
  `quota_type` int(11) NULL DEFAULT NULL COMMENT '1:有配额，2：没有配额',
  `is_deleted` int(11) NULL DEFAULT 0 COMMENT '是否删除',
  `type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'org',
  `expand` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT 'cube-studio:项目拓展字段',
  PRIMARY KEY (`project_id`) USING BTREE,
  UNIQUE INDEX `project_code`(`project_code`) USING BTREE,
  INDEX `vdc_code`(`vdc_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 121 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_project_bak0117
-- ----------------------------
DROP TABLE IF EXISTS `sys_project_bak0117`;
CREATE TABLE `sys_project_bak0117`  (
  `project_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `project_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '项目名称',
  `project_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `vdc_code` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '组织编码',
  `project_status` tinyint(4) NULL DEFAULT NULL COMMENT '项目状态(0: 失效    1:正常)',
  `project_desc` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '项目描述',
  `crt_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `crt_user_id` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `last_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `last_user_id` bigint(20) NULL DEFAULT NULL COMMENT '最后修改人',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `project_version` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '当前版本',
  `leader` bigint(20) NULL DEFAULT NULL COMMENT '项目负责人',
  `quota_type` int(11) NULL DEFAULT NULL COMMENT '1:有配额，2：没有配额',
  `is_deleted` int(11) NULL DEFAULT 0 COMMENT '是否删除',
  `type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'cube-studio:项目类型',
  `expand` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT 'cube-studio:项目拓展字段',
  PRIMARY KEY (`project_id`) USING BTREE,
  UNIQUE INDEX `project_code`(`project_code`) USING BTREE,
  INDEX `vdc_code`(`vdc_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 75 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_project_bak0223
-- ----------------------------
DROP TABLE IF EXISTS `sys_project_bak0223`;
CREATE TABLE `sys_project_bak0223`  (
  `project_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `project_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '项目名称',
  `project_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `vdc_code` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '组织编码',
  `project_status` tinyint(4) NULL DEFAULT NULL COMMENT '项目状态(0: 失效    1:正常)',
  `project_desc` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '项目描述',
  `crt_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `crt_user_id` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `last_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `last_user_id` bigint(20) NULL DEFAULT NULL COMMENT '最后修改人',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `project_version` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '当前版本',
  `leader` bigint(20) NULL DEFAULT NULL COMMENT '项目负责人',
  `quota_type` int(11) NULL DEFAULT NULL COMMENT '1:有配额，2：没有配额',
  `is_deleted` int(11) NULL DEFAULT 0 COMMENT '是否删除',
  `type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'cube-studio:项目类型',
  `expand` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT 'cube-studio:项目拓展字段',
  PRIMARY KEY (`project_id`) USING BTREE,
  UNIQUE INDEX `project_code`(`project_code`) USING BTREE,
  INDEX `vdc_code`(`vdc_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 76 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_project_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_project_user`;
CREATE TABLE `sys_project_user`  (
  `project_user_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `project_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `crt_time` datetime NOT NULL,
  `crt_user` bigint(20) NOT NULL,
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_time` datetime NULL DEFAULT NULL COMMENT 'cube-studio：最后修改时间',
  `last_user_id` bigint(20) NULL DEFAULT NULL COMMENT 'cube-studio：修改时间的人',
  `role` enum('dev','ops','creator') CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'cube-studio：权限(\'dev\',\'ops\',\'creator\')',
  PRIMARY KEY (`project_user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 239 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '项目关联用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_project_user_20240830
-- ----------------------------
DROP TABLE IF EXISTS `sys_project_user_20240830`;
CREATE TABLE `sys_project_user_20240830`  (
  `project_user_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `project_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `crt_time` datetime NOT NULL,
  `crt_user` bigint(20) NOT NULL,
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `last_time` datetime NULL DEFAULT NULL COMMENT 'cube-studio：最后修改时间',
  `last_user_id` bigint(20) NULL DEFAULT NULL COMMENT 'cube-studio：修改时间的人',
  `role` enum('dev','ops','creator') CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'cube-studio：权限(\'dev\',\'ops\',\'creator\')',
  PRIMARY KEY (`project_user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 152 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '项目关联用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_public_cloud_day
-- ----------------------------
DROP TABLE IF EXISTS `sys_public_cloud_day`;
CREATE TABLE `sys_public_cloud_day`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `cloud_count` int(11) NULL DEFAULT 0 COMMENT '云主机总数',
  `run_count` int(11) NULL DEFAULT 0 COMMENT '运行主机总数',
  `stop_count` int(11) NULL DEFAULT 0 COMMENT '停止主机总数',
  `other_count` int(11) NULL DEFAULT NULL COMMENT '其他主机总数',
  `abnormal_count` int(11) NULL DEFAULT 0 COMMENT '异常主机总数',
  `about_expire_count` int(11) NULL DEFAULT 0 COMMENT '即将过期主机总数',
  `expire_count` int(11) NULL DEFAULT 0 COMMENT '过期主机总数',
  `cpu_count` int(11) NULL DEFAULT 0 COMMENT 'CPU总核数',
  `disk_count` int(11) NULL DEFAULT 0 COMMENT '存储大小',
  `snapshot_count` int(11) NULL DEFAULT 0 COMMENT '快照个数',
  `network_count` int(11) NULL DEFAULT 0 COMMENT '弹性IP个数',
  `security_group_count` int(11) NULL DEFAULT 0 COMMENT '安全组个数',
  `rds_count` int(11) NULL DEFAULT 0 COMMENT 'redis个数',
  `lvs_count` int(11) NULL DEFAULT 0 COMMENT '负载均衡个数',
  `file_disk_count` int(11) NULL DEFAULT 0 COMMENT '文件个数',
  `object_disk_count` int(11) NULL DEFAULT 0 COMMENT '对象存储个数',
  `cache_count` int(11) NULL DEFAULT 0 COMMENT '缓存服务个数',
  `message_count` int(11) NULL DEFAULT 0 COMMENT '消息服务个数',
  `account_id` int(11) NULL DEFAULT NULL COMMENT '账户ID',
  `tenant_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `sysproject` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '-1',
  `ref_id` int(11) NULL DEFAULT NULL,
  `syn_time` datetime NULL DEFAULT NULL COMMENT '同步时间',
  `only_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_user` bigint(64) NULL DEFAULT NULL COMMENT '创建人',
  `create_dept` bigint(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint(64) NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `is_deleted` int(2) NOT NULL DEFAULT 0 COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '可视化表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_quota
-- ----------------------------
DROP TABLE IF EXISTS `sys_quota`;
CREATE TABLE `sys_quota`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '租户ID',
  `res_pool_id` bigint(20) NOT NULL COMMENT '资源池ID',
  `ascription_target_id` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '归属ID',
  `ascription_target_type` int(2) NULL DEFAULT NULL COMMENT '1:VDC_CODE   2:项目ID',
  `total_server` bigint(20) NULL DEFAULT NULL COMMENT '主机总量',
  `total_cpu` bigint(20) NULL DEFAULT NULL COMMENT '配额总CPU数(核)',
  `total_volume_size` bigint(20) NULL DEFAULT NULL COMMENT '配额总存储容量(GB)',
  `total_volume` bigint(20) NULL DEFAULT NULL COMMENT '配额总硬盘数量(个)',
  `total_volume_snapshot` bigint(20) NULL DEFAULT NULL COMMENT '配额总硬盘快照数量(个)',
  `total_memory_size` bigint(20) NULL DEFAULT NULL COMMENT '配额总内存数(MB)',
  `total_vpc` bigint(20) NULL DEFAULT NULL COMMENT '配额总网络数(个)',
  `total_subnet` bigint(20) NULL DEFAULT NULL COMMENT '配额总子网数(个)',
  `total_floatingip` bigint(20) NULL DEFAULT NULL COMMENT '配额总浮动IP数(个)',
  `used_server` bigint(20) NULL DEFAULT 0 COMMENT '配额已使用主机数(个)',
  `used_memory_size` bigint(20) NULL DEFAULT 0 COMMENT '配额已使用内存数(MB)',
  `used_volume_size` bigint(20) NULL DEFAULT 0 COMMENT '配额已使用总存储容量(GB)',
  `used_volume` bigint(20) NULL DEFAULT 0 COMMENT '配额已使用硬盘数量(个)',
  `used_volume_snapshot` bigint(20) NULL DEFAULT 0 COMMENT '配额已使用硬盘快照数量(个)',
  `used_cpu` bigint(20) NULL DEFAULT 0 COMMENT '配额已使用CPU数(核)',
  `used_vpc` bigint(20) NULL DEFAULT 0 COMMENT '配额已使用网络数(个)',
  `used_subnet` bigint(20) NULL DEFAULT 0 COMMENT '配额已使用子网数(个)',
  `used_floatingip` bigint(20) NULL DEFAULT 0 COMMENT '配额已使用浮动IP数(个)',
  `allocating_cpu` bigint(20) NOT NULL DEFAULT 0 COMMENT '配额申请中CPU数(核)',
  `allocating_server` bigint(20) NOT NULL DEFAULT 0 COMMENT '配额申请中主机数(个)',
  `allocating_volume_size` bigint(20) NOT NULL DEFAULT 0 COMMENT '配额申请中存储容量(GB)',
  `allocating_volume` bigint(20) NOT NULL DEFAULT 0 COMMENT '配额申请中硬盘数量(个)',
  `allocating_volume_snapshot` bigint(20) NOT NULL DEFAULT 0 COMMENT '配额申请中硬盘快照数量(个)',
  `allocating_memory_size` bigint(20) NOT NULL DEFAULT 0 COMMENT '配额申请中内存数(MB)',
  `allocating_vpc` bigint(20) NOT NULL DEFAULT 0 COMMENT '配额申请中网络数(个)',
  `allocating_subnet` bigint(20) NOT NULL DEFAULT 0 COMMENT '配额申请中子网数(个)',
  `allocating_floatingip` bigint(20) NOT NULL DEFAULT 0 COMMENT '配额申请中浮动IP数(个)',
  `gpu` varchar(5000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '配额Gpu',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `tenant_id_ref_id_obj_id_obj_type`(`tenant_id`, `res_pool_id`, `ascription_target_id`, `ascription_target_type`) USING BTREE,
  INDEX `tenantId`(`tenant_id`) USING BTREE,
  INDEX `ref_id`(`res_pool_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 268 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '系统配额表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_quota_allocation
-- ----------------------------
DROP TABLE IF EXISTS `sys_quota_allocation`;
CREATE TABLE `sys_quota_allocation`  (
  `allocation_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '配额分配记录ID',
  `quota_id` bigint(20) NOT NULL COMMENT '使用的配额ID',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '租户ID',
  `use_type` int(11) NOT NULL COMMENT '标记操作为 增加还是扣减(0:增加  1:扣减)',
  `use_server_count` int(11) NOT NULL COMMENT '使用主机数',
  `use_cpu_count` int(11) NOT NULL COMMENT '使用CPU数',
  `use_volume_size` bigint(20) NOT NULL COMMENT '使用存储容量(GB)',
  `use_volume_count` int(11) NOT NULL COMMENT '使用存储数',
  `use_snapshot_count` int(11) NOT NULL COMMENT '使用快照数',
  `use_memory_size` bigint(20) NOT NULL COMMENT '使用内存容量(GB)',
  `use_vpc_count` int(11) NOT NULL COMMENT '使用私有网络数',
  `use_subnet_count` int(11) NOT NULL COMMENT '使用子网数',
  `use_floatingip_count` int(11) NOT NULL COMMENT '使用浮动IP数',
  `allocation_time` datetime NOT NULL COMMENT '分配时间',
  `process_status` int(11) NOT NULL COMMENT '处理状态(0:处理中    1:已完成)',
  `allocation_status` int(11) NOT NULL COMMENT '分配状态(0:预占中    10:已提交   -10:已回滚)',
  `transaction_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '事务ID(由业务方设置)',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `ref_allocation_id` bigint(20) NULL DEFAULT NULL COMMENT '关联ID',
  `ref_allocation_type` int(11) NULL DEFAULT NULL COMMENT '关联类型(0: 从上级配额分配资源   1:回滚)',
  PRIMARY KEY (`allocation_id`) USING BTREE,
  UNIQUE INDEX `transaction_id`(`transaction_id`) USING BTREE,
  INDEX `quota_id`(`quota_id`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 764 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '配置分配记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_quota_new
-- ----------------------------
DROP TABLE IF EXISTS `sys_quota_new`;
CREATE TABLE `sys_quota_new`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '租户ID',
  `res_pool_id` bigint(20) NOT NULL COMMENT '资源池ID',
  `ascription_target_id` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '归属ID',
  `ascription_target_type` int(2) NULL DEFAULT NULL COMMENT '1:VDC_CODE   2:项目ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `tenant_id_ref_id_obj_id_obj_type`(`tenant_id`, `res_pool_id`, `ascription_target_id`, `ascription_target_type`) USING BTREE,
  INDEX `tenantId`(`tenant_id`) USING BTREE,
  INDEX `ref_id`(`res_pool_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 95 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '系统配额表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_quota_paramter
-- ----------------------------
DROP TABLE IF EXISTS `sys_quota_paramter`;
CREATE TABLE `sys_quota_paramter`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `quota_id` int(11) NOT NULL COMMENT 'quota_id',
  `total` bigint(20) NULL DEFAULT NULL COMMENT '总量',
  `quota` bigint(20) NULL DEFAULT NULL COMMENT '配额',
  `reserve` bigint(20) NULL DEFAULT NULL COMMENT '预留',
  `type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '类型 0-实例数 1-CPU数 2-内存 3-GPU 4-NPU',
  `key` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'GPU、NPU使用对应型号信息',
  `unit` bigint(20) NULL DEFAULT NULL COMMENT '单位(对应GPU或NPU卡显存容量）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 550 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '系统配额表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_quota_paramter_copy1
-- ----------------------------
DROP TABLE IF EXISTS `sys_quota_paramter_copy1`;
CREATE TABLE `sys_quota_paramter_copy1`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '租户ID',
  `res_pool_id` bigint(20) NOT NULL COMMENT '资源池ID',
  `ascription_target_id` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '归属ID',
  `ascription_target_type` int(2) NULL DEFAULT NULL COMMENT '1:VDC_CODE   2:项目ID',
  `total` bigint(20) NULL DEFAULT NULL COMMENT '总量',
  `used` bigint(20) NULL DEFAULT NULL COMMENT '已使用',
  `quota` bigint(20) NULL DEFAULT NULL COMMENT '配额',
  `allocate` bigint(20) NULL DEFAULT NULL COMMENT '已分配配额',
  `reserve` bigint(20) NULL DEFAULT NULL COMMENT '预留',
  `type` bigint(20) NULL DEFAULT NULL COMMENT '类型 0-实例数 1-CPU数 2-内存 3-GPU 4-NPU',
  `key` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'GPU、NPU使用对应型号信息',
  `unit` bigint(20) NULL DEFAULT NULL COMMENT '单位(对应GPU或NPU卡显存容量）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `tenant_id_ref_id_obj_id_obj_type`(`tenant_id`, `res_pool_id`, `ascription_target_id`, `ascription_target_type`) USING BTREE,
  INDEX `tenantId`(`tenant_id`) USING BTREE,
  INDEX `ref_id`(`res_pool_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '系统配额表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_region
-- ----------------------------
DROP TABLE IF EXISTS `sys_region`;
CREATE TABLE `sys_region`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '区划编号',
  `res_pool_type_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '资源池类型编码(根节点为:__root)',
  `out_region_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '外部编码',
  `parent_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父区划编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ancestors` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '祖区划编号',
  `level` int(2) NULL DEFAULT NULL COMMENT '层级',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `tenant_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code`) USING BTREE,
  INDEX `res_type_id`(`res_pool_type_code`) USING BTREE,
  INDEX `out_region_code`(`out_region_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 544 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '行政区划表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_region_area_ref
-- ----------------------------
DROP TABLE IF EXISTS `sys_region_area_ref`;
CREATE TABLE `sys_region_area_ref`  (
  `area_ref_id` int(11) NOT NULL AUTO_INCREMENT,
  `region_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'REGION CODE',
  `area_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '地区编码',
  PRIMARY KEY (`area_ref_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'REGION与地区关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_region_copy
-- ----------------------------
DROP TABLE IF EXISTS `sys_region_copy`;
CREATE TABLE `sys_region_copy`  (
  `code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '区划编号',
  `parent_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父区划编号',
  `ancestors` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '祖区划编号',
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区划名称',
  `province_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省级区划编号',
  `province_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '省级名称',
  `city_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市级区划编号',
  `city_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '市级名称',
  `district_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区级区划编号',
  `district_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '区级名称',
  `town_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '镇级区划编号',
  `town_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '镇级名称',
  `village_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '村级区划编号',
  `village_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '村级名称',
  `level` int(2) NULL DEFAULT NULL COMMENT '层级',
  `sort` int(2) NULL DEFAULT NULL COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '行政区划表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_res_pool
-- ----------------------------
DROP TABLE IF EXISTS `sys_res_pool`;
CREATE TABLE `sys_res_pool`  (
  `res_pool_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '租户ID',
  `res_pool_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '关联名称',
  `resource_count` int(11) NULL DEFAULT 0 COMMENT '关联的实例数',
  `environment_id` bigint(20) NULL DEFAULT NULL COMMENT '云环境ID',
  `region_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '本地区域编码',
  `out_ref_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '外部关联ID',
  `sync_status` int(3) NULL DEFAULT NULL COMMENT '(0: 待同步 5:同步中  10:同步完成  11:部分成功  -10:同步失败)',
  `err_reason` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '同步错误原因',
  `last_sync_time` timestamp NULL DEFAULT NULL COMMENT '最后同步时间',
  `status` int(3) NULL DEFAULT NULL COMMENT '(0:初始  10:正常   -10:异常)',
  `create_vdc_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人的VDC',
  `create_user_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人',
  PRIMARY KEY (`res_pool_id`) USING BTREE,
  UNIQUE INDEX `tenant_id_out_ref_id`(`tenant_id`, `out_ref_id`) USING BTREE,
  INDEX `account_id`(`environment_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 233 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '资源池表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_res_pool_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_res_pool_type`;
CREATE TABLE `sys_res_pool_type`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `res_pool_type_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源类型名称',
  `res_pool_type_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源类型编码',
  `res_pool_type_logo` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源logo',
  `status` int(3) NULL DEFAULT NULL COMMENT '资源状态  1:正常  0:失效',
  `cloud_type` int(3) NULL DEFAULT NULL COMMENT '资源分组类型(1: 公有云   2:私有云)',
  `is_deleted` int(2) NULL DEFAULT NULL,
  `keypair_user` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '默认密钥帐号',
  `admin_user` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '默认超管帐号',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`res_pool_type_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '云环境基础信息定义表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_res_pool_vdc_ref
-- ----------------------------
DROP TABLE IF EXISTS `sys_res_pool_vdc_ref`;
CREATE TABLE `sys_res_pool_vdc_ref`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `environment_id` bigint(20) NOT NULL COMMENT '云环境ID',
  `res_pool_id` bigint(20) NOT NULL COMMENT '资源池ID',
  `vdc_code` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'VDC编码',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '租户ID',
  `allocation_method` int(1) NOT NULL COMMENT '1:共享使用    2:独立使用',
  `crt_user` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '创建用户',
  `crt_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_user` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '更新用户',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `account_id_ref_id_obj_type_obj_id_tenant_id`(`environment_id`, `res_pool_id`, `vdc_code`, `tenant_id`) USING BTREE,
  INDEX `account_id`(`environment_id`) USING BTREE,
  INDEX `ref_id`(`res_pool_id`) USING BTREE,
  INDEX `obj_type_obj_id`(`vdc_code`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 756 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '资源池VDC授权表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_res_pool_vdc_ref_20241009
-- ----------------------------
DROP TABLE IF EXISTS `sys_res_pool_vdc_ref_20241009`;
CREATE TABLE `sys_res_pool_vdc_ref_20241009`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `environment_id` bigint(20) NOT NULL COMMENT '云环境ID',
  `res_pool_id` bigint(20) NOT NULL COMMENT '资源池ID',
  `vdc_code` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'VDC编码',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '租户ID',
  `allocation_method` int(1) NOT NULL COMMENT '1:共享使用    2:独立使用',
  `crt_user` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '创建用户',
  `crt_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_user` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '更新用户',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `account_id_ref_id_obj_type_obj_id_tenant_id`(`environment_id`, `res_pool_id`, `vdc_code`, `tenant_id`) USING BTREE,
  INDEX `account_id`(`environment_id`) USING BTREE,
  INDEX `ref_id`(`res_pool_id`) USING BTREE,
  INDEX `obj_type_obj_id`(`vdc_code`) USING BTREE,
  INDEX `tenant_id`(`tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 555 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '资源池VDC授权表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_resource
-- ----------------------------
DROP TABLE IF EXISTS `sys_resource`;
CREATE TABLE `sys_resource`  (
  `res_id` int(11) NOT NULL AUTO_INCREMENT,
  `res_pool_type_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源池类型编码(如:openstack)',
  `res_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源定义编码(如:server)',
  `res_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源名称',
  `res_order` int(11) NOT NULL DEFAULT 0 COMMENT '资源排序(用于资源视图)',
  `res_status` int(11) NOT NULL DEFAULT 0 COMMENT '资源状态(0:失效  1:正常)',
  `show_status` int(11) NOT NULL DEFAULT 0 COMMENT '显示状态(0:否  1:是)',
  `notify_topic_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '废弃',
  `res_interval` int(11) NOT NULL COMMENT '同步周期值',
  `res_interval_type` int(11) NOT NULL COMMENT '同步周期(0:秒  1:分钟  2:小时  3:天)',
  `query_transport_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '同步时使用的请求Path',
  `query_root_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '废弃',
  `transport_version` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '废弃',
  PRIMARY KEY (`res_id`) USING BTREE,
  UNIQUE INDEX `res_type_id_task_code`(`res_pool_type_code`, `res_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 168 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '资源实体定义表(如：磁盘、实例)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_resource_event
-- ----------------------------
DROP TABLE IF EXISTS `sys_resource_event`;
CREATE TABLE `sys_resource_event`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '事件编码(参考sys_resource_event_type)',
  `res_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源编码',
  `res_pool_type_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源池类型编码',
  `event_res_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '事件资源编码(可能与res_code不同) 如:在server下触发volume的事件',
  `show_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '显示按钮名称',
  `show_expression` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '显示条件表达式',
  `show_layout` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '显示布局(confirm(弹出确认框)、modal (弹层)、table-radio(单选table列表)、table-checkbox(多选table列表)、drawer(抽屉)、transfer(穿梭框)、open-tab(打开tab页))',
  `show_position` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '显示事件的位置(menu: 每行操作栏    menuLeft:左侧     menuRight:右侧)',
  `show_component` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '显示的组件(dropdown,button,toolbar,customize)',
  `show_form_content` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '自定义表单内容',
  `show_form_version` int(11) NULL DEFAULT NULL COMMENT '自定义表单版本号(用于控制前端更新)',
  `show_order` int(11) NULL DEFAULT NULL COMMENT '排序字段',
  `status` int(11) NOT NULL COMMENT '10: 有效  -10:失效',
  `param` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '事件参数',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `event_code_res_code_res_pool_type_code_event_res_code`(`event_code`, `res_code`, `res_pool_type_code`, `event_res_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1254 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '资源事件关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_resource_event_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_resource_event_type`;
CREATE TABLE `sys_resource_event_type`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '事件名称',
  `event_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '事件编码',
  `status` int(11) NULL DEFAULT NULL COMMENT '状态(0:停用   1:启用)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `event_code`(`event_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '资源事件定义表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_resource_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_resource_type`;
CREATE TABLE `sys_resource_type`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `res_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源编码',
  `status` int(11) NULL DEFAULT NULL COMMENT '状态',
  `uri` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源API地址',
  `res_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service
-- ----------------------------
DROP TABLE IF EXISTS `sys_service`;
CREATE TABLE `sys_service`  (
  `id` bigint(11) NOT NULL,
  `service_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务名字',
  `service_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务编码',
  `create_time` datetime NULL DEFAULT NULL,
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `update_time` datetime NULL DEFAULT NULL,
  `create_user` bigint(20) NULL DEFAULT NULL,
  `update_user` bigint(20) NULL DEFAULT NULL,
  `is_deleted` int(11) NULL DEFAULT 0,
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_apply_info
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_apply_info`;
CREATE TABLE `sys_service_apply_info`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `apply_no` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '申请单号',
  `service_id` bigint(20) NULL DEFAULT NULL,
  `obj_type` int(11) NULL DEFAULT NULL COMMENT '对象类型(1:组织  2:项目)',
  `obj_id` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `apply_content` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `own_uid` bigint(11) NULL DEFAULT NULL COMMENT '拥有人用户ID,资源归属非个人时默认值-1',
  `crt_uid` bigint(11) NOT NULL COMMENT '创建用户ID',
  `crt_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `status` int(11) NULL DEFAULT NULL COMMENT '申请单状态(0:初始   5:处理中  10:已完成  -10:处理失败)',
  `audit_status` int(11) NULL DEFAULT NULL COMMENT '0:待审批1:审核已保存  10:通过 -10:拒绝',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `is_deleted` int(11) NULL DEFAULT 0,
  `audit_content` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '审核意见',
  `process_result` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '处理结果',
  `apply_source` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '申请来源，appStore:应用市场',
  `request_heads` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '申请请求头，包含公共信息',
  `notify_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '通知id',
  `notify_utc_timestamp` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '通知服务端发送时间',
  `notify_desc` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '通知描述说明',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1782721908534616067 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_bpm
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_bpm`;
CREATE TABLE `sys_service_bpm`  (
  `id` int(9) NOT NULL AUTO_INCREMENT,
  `dict_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '关联字典编码',
  `bpm_definition_id` int(11) NULL DEFAULT NULL,
  `bpm_definition_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `status` int(2) NULL DEFAULT NULL,
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `create_user_id` bigint(64) NULL DEFAULT NULL,
  `update_user_id` bigint(64) NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '关联流程表-系统需要审批的地方统一在这个关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_service_catalog
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_catalog`;
CREATE TABLE `sys_service_catalog`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `parent_code` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `vdc_code` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `crt_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_category
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_category`;
CREATE TABLE `sys_service_category`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_Name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务类别名称',
  `category_Type` int(11) NULL DEFAULT 0 COMMENT '服务类别类型',
  `vdc_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `ctime` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `tenant_id` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '服务分类' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_content_attachment_file
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_content_attachment_file`;
CREATE TABLE `sys_service_content_attachment_file`  (
  `attachement_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `attachement_file_name` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '原始文件名',
  `file_path` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '文件存放路径',
  `create_time` datetime NULL DEFAULT NULL,
  `file_size` int(11) NULL DEFAULT NULL COMMENT '文件大小',
  `file_md5` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '文件md5值',
  `chunk_count` int(11) NULL DEFAULT NULL COMMENT 'chunk数量',
  `service_conent_id` bigint(20) NULL DEFAULT NULL COMMENT '服务ID',
  `attachement_tenant_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  PRIMARY KEY (`attachement_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '服务目录附件' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_contents
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_contents`;
CREATE TABLE `sys_service_contents`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contents_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务名称',
  `contents_icon` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务图标',
  `contents_visibility` int(11) NULL DEFAULT 1 COMMENT '资源可见性',
  `contents_describe` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务详情',
  `contents_assembly` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务组件',
  `contents_approval` int(11) NULL DEFAULT 1 COMMENT '是否需要审批',
  `contents_flow` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '关联流程',
  `contents_status` varchar(11) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '1' COMMENT '开启状态,1:启用，0：停用',
  `tenant_id` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `obj_type` int(11) NULL DEFAULT NULL,
  `obj_id` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `create_user` bigint(20) NULL DEFAULT NULL,
  `create_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `ctime` datetime NULL DEFAULT NULL,
  `other_Url` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `history` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '1.0.1',
  `file_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `temp_id` int(100) NULL DEFAULT NULL COMMENT '资源模板',
  `temp_history` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源模板版本',
  `service_resource_type` int(11) NULL DEFAULT 1 COMMENT '服务组件类型',
  `app_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '应用ID',
  `need_quota` int(11) NULL DEFAULT 0 COMMENT '是否需要走配额,1:不需要，0：需要',
  `publish_status` int(11) NULL DEFAULT 1 COMMENT '服务发布状态,1:已保存，2：应用市场校验通过，3：校验失败，4：发布成功，5：发布失败,6:草稿',
  `res_temp_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源模版编码',
  `publish_audit` int(11) NULL DEFAULT NULL COMMENT '上架是否需要走审批,1:不需要，0：需要',
  `publish_audit_flow_id` int(11) NULL DEFAULT NULL COMMENT '上架审批流程ID',
  `os_type` varchar(18) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务部署方式：kvm,docker,lxc,bm',
  `editor_content` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '保存描述的格式，用于描述的富文本显示',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1324 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '服务目录-服务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_contents_category
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_contents_category`;
CREATE TABLE `sys_service_contents_category`  (
  `id` bigint(11) NOT NULL AUTO_INCREMENT,
  `contentsId` int(11) NULL DEFAULT NULL,
  `categoryId` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1564525538626646018 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_contents_node
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_contents_node`;
CREATE TABLE `sys_service_contents_node`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `node_name` varchar(600) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `contents_id` int(11) NULL DEFAULT NULL,
  `contents_history` varchar(300) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `start_script` varchar(3000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `init_script` varchar(3000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `stop_script` varchar(3000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `ctime` datetime NULL DEFAULT NULL,
  `image` varchar(192) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_contents_scripts
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_contents_scripts`;
CREATE TABLE `sys_service_contents_scripts`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `scripts_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本名称',
  `description` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本描述',
  `scripts_category` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本类别',
  `scripts_scripts` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '脚本',
  `ctime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `scripts_history` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '版本',
  `tenant_id` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `scripts_id` int(11) NULL DEFAULT NULL,
  `contents_id` int(11) NULL DEFAULT NULL,
  `contents_history` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `scripts_type` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `group_nanotube` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源组纳管 1、纳管 0、不纳管',
  `node_id` int(11) NULL DEFAULT NULL COMMENT '节点ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_contents_scripts_group
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_contents_scripts_group`;
CREATE TABLE `sys_service_contents_scripts_group`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `scripts_id` int(11) NULL DEFAULT NULL COMMENT '脚本ID',
  `scripts_group_id` int(11) NULL DEFAULT NULL COMMENT '脚本分组id',
  `scripts_history` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本版本',
  `contents_id` int(11) NULL DEFAULT NULL COMMENT '服务目录ID',
  `contents_history` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务目录版本',
  `temp_id` int(11) NULL DEFAULT NULL COMMENT '模板Id',
  `temp_history` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '模板版本',
  `range_max_num` int(11) NULL DEFAULT NULL COMMENT '分组节点范围最大数量',
  `range_min_num` int(11) NULL DEFAULT NULL COMMENT '分组节点范围最小数量',
  `step_num` int(11) NULL DEFAULT NULL COMMENT '分组节点步长',
  `ctime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_contents_scripts_param
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_contents_scripts_param`;
CREATE TABLE `sys_service_contents_scripts_param`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `param_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数名称',
  `param_value` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数值',
  `param_desc` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数描述',
  `param_type` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本类型 1、input 2、select 3、checkbox 4、radio 5、textarea',
  `param_required` tinyint(1) NULL DEFAULT NULL COMMENT '配置是否必填',
  `ctime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `scripts_id` int(11) NULL DEFAULT NULL COMMENT '脚本id',
  `contents_id` int(11) NULL DEFAULT NULL COMMENT '服务目录id',
  `default_type` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数类型 ',
  `default_value_type` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数值类型 1、服务器资源ID 2、服务器外网IP 3、服务器内网IP 4、服务器名称 5、子网ID',
  `scripts_history` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `contents_history` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `node_id` int(11) NULL DEFAULT NULL COMMENT '节点ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_contents_template
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_contents_template`;
CREATE TABLE `sys_service_contents_template`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contents_id` int(11) NULL DEFAULT NULL COMMENT '服务目录id',
  `temp_id` int(11) NULL DEFAULT NULL COMMENT '资源模板Id',
  `ctime` datetime NULL DEFAULT NULL,
  `temp_param_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '配置名称',
  `temp_param_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '配置字段',
  `temp_param_type` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '配置类型 1、input 2、select 3、checkbox 4、radio 5、textarea',
  `temp_param_decs` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '配置字段描述',
  `temp_param_value` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '配置默认值',
  `temp_param_required` tinyint(1) NULL DEFAULT NULL COMMENT '配置是否必填',
  `temp_param_visible` tinyint(1) NULL DEFAULT NULL COMMENT '是否可见',
  `temp_param_audit` tinyint(1) NULL DEFAULT NULL COMMENT '审核可编辑',
  `temp_param_canVisible` tinyint(1) NULL DEFAULT NULL COMMENT '可见是否可以编辑',
  `temp_param_canAudit` tinyint(1) NULL DEFAULT NULL COMMENT '审核是否可编辑',
  `temp_param_env` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '支持云服务',
  `contents_history` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务目录版本',
  `contents_scripts_group_id` int(11) NULL DEFAULT NULL COMMENT '分组ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 169 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_order
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_order`;
CREATE TABLE `sys_service_order`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `service_id` bigint(20) NULL DEFAULT NULL,
  `obj_type` int(11) NULL DEFAULT NULL COMMENT '对象类型(1:组织  2:项目)',
  `obj_id` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `order_content` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  `own_uid` bigint(11) NULL DEFAULT NULL COMMENT '拥有人用户ID,资源归属非个人时默认值-1',
  `crt_uid` bigint(11) NOT NULL COMMENT '创建用户ID',
  `crt_time` datetime NULL DEFAULT NULL,
  `flow_id` int(11) NULL DEFAULT NULL COMMENT '流程定义ID',
  `status` int(11) NULL DEFAULT NULL COMMENT '服务订单状态(0:初始   5:处理中  10:已完成  -10:处理失败)',
  `audit_status` int(11) NULL DEFAULT NULL COMMENT '0:待审批  10:通过 -10:拒绝',
  `processor_topic` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '服务订单异步处理消息topic',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `is_deleted` int(11) NULL DEFAULT 0,
  `audit_content` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '审核意见',
  `process_result` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '处理结果',
  `cloud_resource_id` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '云资源ID',
  `order_source` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '订单来源，appStore:应用市场',
  `work_flow_instance_key` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'zeebe流程实例ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1990725682450685954 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_resource
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_resource`;
CREATE TABLE `sys_service_resource`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `res_code` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `res_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `logo_url` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `res_type` int(11) NULL DEFAULT NULL,
  `build_script` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_resource_bak
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_resource_bak`;
CREATE TABLE `sys_service_resource_bak`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `res_code` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `res_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `logo_url` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `res_type` int(11) NULL DEFAULT NULL,
  `build_script` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_scripts
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_scripts`;
CREATE TABLE `sys_service_scripts`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `scripts_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本名称',
  `description` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本描述',
  `scripts_category` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本分类',
  `scripts_scripts` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '脚本',
  `create_user` bigint(20) NULL DEFAULT NULL,
  `ctime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `scripts_history` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '版本',
  `tenant_id` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `utime` datetime NULL DEFAULT NULL,
  `scripts_type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'Shell、Playbook',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_scripts_group
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_scripts_group`;
CREATE TABLE `sys_service_scripts_group`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `scripts_id` int(11) NULL DEFAULT NULL COMMENT '脚本ID',
  `scripts_hid` int(11) NULL DEFAULT NULL COMMENT '脚本历史id',
  `group_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '分组名称',
  `ctime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `group_util` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本规则符号（<,>,=,无限）1、2、3、0',
  `group_util_num` int(11) NULL DEFAULT NULL COMMENT '数量限制',
  `history` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本版本',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_scripts_group_variable
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_scripts_group_variable`;
CREATE TABLE `sys_service_scripts_group_variable`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `scripts_group_id` int(11) NULL DEFAULT NULL COMMENT '脚本分组ID',
  `variable_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `variable_value` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `ctime` datetime NULL DEFAULT NULL,
  `scripts_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_scripts_history
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_scripts_history`;
CREATE TABLE `sys_service_scripts_history`  (
  `id` int(11) NULL DEFAULT NULL COMMENT '脚本Id',
  `scripts_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本名称',
  `description` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本描述',
  `scripts_category` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本类别',
  `scripts_scripts` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '脚本',
  `ctime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `scripts_history` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'REV1' COMMENT '版本',
  `tenant_id` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `utime` datetime NULL DEFAULT NULL,
  `hid` int(11) NOT NULL AUTO_INCREMENT,
  `scripts_type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`hid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_scripts_param
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_scripts_param`;
CREATE TABLE `sys_service_scripts_param`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `param_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数名称',
  `param_value` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数值',
  `param_desc` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数描述',
  `ctime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `scripts_id` int(11) NOT NULL COMMENT '脚本id',
  `default_type` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'text',
  `history` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '版本',
  `param_type` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本类型 1、input 2、select 3、checkbox 4、radio 5、textarea',
  `param_required` tinyint(1) NULL DEFAULT NULL COMMENT '配置是否必填',
  `default_value_type` varchar(2) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数值类型 1、服务器资源ID 2、服务器外网IP 3、服务器内网IP 4、服务器名称 5、子网ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_template
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_template`;
CREATE TABLE `sys_service_template`  (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `temp_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源模板名称',
  `temp_desc` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源模板描述',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户',
  `vdc_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'vdcCode',
  `create_user` bigint(20) NULL DEFAULT NULL,
  `ctime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `utime` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `res_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源Code',
  `latest_history` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'REV1' COMMENT '版本',
  `is_static` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '1固定云环境  2非固定云环境',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_template_area
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_template_area`;
CREATE TABLE `sys_service_template_area`  (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `res_pool_id` int(11) NULL DEFAULT NULL,
  `temp_id` int(11) NULL DEFAULT NULL,
  `imgs_id` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '多个镜像ID',
  `area_id` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '可用区',
  `flavor_id` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '多个规格id',
  `network_id` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '多个网络id',
  `security_groups_id` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '多个安全组',
  `charging_mode` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '计费方式 \"0\"包年包月 \"1\"按量计费',
  `login_type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '登录方式',
  `sys_disk_type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '系统盘类型',
  `sys_min_disk` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '系统盘范围大小，最小',
  `sys_max_disk` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '系统盘范围大小，最大',
  `data_disk_type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '数据盘类型',
  `data_min_disk` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '数据盘范围大小，最小',
  `data_max_disk` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '数据盘范围大小，最大',
  `data_max_count` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '数据盘限定最大个数',
  `pay_type` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '付费类型',
  `bandwidth_max` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '带宽最小',
  `bandwidth_min` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '带宽最大',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户Id',
  `res_type_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `account_id` int(11) NULL DEFAULT NULL COMMENT '账号',
  `res_pool_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '云环境名称',
  `zone_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '区域名称',
  `imgs_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `flavor_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `network_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `security_groups_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `latest_history` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_template_history
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_template_history`;
CREATE TABLE `sys_service_template_history`  (
  `id` int(10) NULL DEFAULT NULL,
  `temp_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源模板名称',
  `temp_desc` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源模板描述',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户',
  `vdc_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'vdcCode',
  `ctime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `utime` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `res_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源Code',
  `latest_history` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'REV1' COMMENT '版本',
  `is_static` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '1固定云环境  2非固定云环境',
  `hid` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`hid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_template_scripts
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_template_scripts`;
CREATE TABLE `sys_service_template_scripts`  (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `temp_id` int(11) NULL DEFAULT NULL COMMENT '模板Id',
  `scripts_id` int(11) NULL DEFAULT NULL COMMENT '脚本id',
  `type` int(11) NULL DEFAULT NULL COMMENT '类型 1、启动脚本 2、操作脚本 3、停止脚本',
  `ctime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `scripts_history` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `latest_history` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_service_template_scripts_param
-- ----------------------------
DROP TABLE IF EXISTS `sys_service_template_scripts_param`;
CREATE TABLE `sys_service_template_scripts_param`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `param_name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数名称',
  `param_value` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数值',
  `param_desc` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '脚本参数描述',
  `ctime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `scripts_id` int(11) NOT NULL COMMENT '脚本id',
  `temp_id` int(11) NULL DEFAULT NULL COMMENT '模板id',
  `default_type` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `temp_scripts_id` int(11) NULL DEFAULT NULL,
  `scripts_history` varchar(11) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_sync_event
-- ----------------------------
DROP TABLE IF EXISTS `sys_sync_event`;
CREATE TABLE `sys_sync_event`  (
  `event_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `batch_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '任务批次号,用于验证唯一',
  `event_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '事件名称',
  `event_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '事件编码',
  `resource_original_id` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源真实ID',
  `environment_id` bigint(20) NOT NULL COMMENT '环境ID',
  `res_pool_id` bigint(20) NOT NULL COMMENT '资源池ID',
  `res_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源ID(标识为 虚拟机|云盘|安全组等)',
  `ascription_target_id` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '归属ID',
  `ascription_target_type` int(2) NOT NULL COMMENT '1:VDC_CODE   2:项目ID',
  `res_pool_type_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源池类型编码(标识是openstack或HCS)',
  `event_param` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '事件参数',
  `event_time` datetime NOT NULL COMMENT '事件开始时间',
  `event_status` int(11) NOT NULL COMMENT '0:待处理  10:正常   -10:错误',
  `err_reason` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '错误原因',
  `sync_status` int(11) NOT NULL COMMENT '0:待同步   10:同步完成',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '任务完成时间',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '租户ID',
  `user_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '任务执行用户ID',
  PRIMARY KEY (`event_id`) USING BTREE,
  UNIQUE INDEX `batch_code`(`batch_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2335 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '资源事件记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_task_execute_target
-- ----------------------------
DROP TABLE IF EXISTS `sys_task_execute_target`;
CREATE TABLE `sys_task_execute_target`  (
  `execute_target_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `job_task_id` bigint(20) NULL DEFAULT NULL COMMENT '任务ID',
  `execute_target_type` int(3) NULL DEFAULT NULL COMMENT '目标类型\n1:虚拟主机ID  ',
  `execute_target_obj_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '目标ID',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `create_user` bigint(20) NULL DEFAULT NULL,
  `update_user` bigint(20) NULL DEFAULT NULL,
  `is_deleted` int(11) NULL DEFAULT 0 COMMENT '是否删除\n1：是\n0：否',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  PRIMARY KEY (`execute_target_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '任务执行目标' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_task_iaas_sync
-- ----------------------------
DROP TABLE IF EXISTS `sys_task_iaas_sync`;
CREATE TABLE `sys_task_iaas_sync`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `res_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源类型',
  `batch_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '同步批次号',
  `environment_id` bigint(20) NOT NULL COMMENT '云环境ID',
  `res_pool_id` bigint(20) NOT NULL COMMENT '资源池ID',
  `sync_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后同步时间',
  `crt_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `sync_status` int(11) NOT NULL COMMENT '0未同步 (10:同步成功  -10:同步失败)',
  `err_reason` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '错误原因',
  `item_count` int(11) NULL DEFAULT 0 COMMENT '同步数量',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `res_pool_type_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '资源池类型',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `task_id_batch_code_ref_id`(`res_code`, `batch_code`, `res_pool_id`) USING BTREE,
  INDEX `task_id`(`res_code`) USING BTREE,
  INDEX `account_id`(`environment_id`) USING BTREE,
  INDEX `ref_id`(`res_pool_id`) USING BTREE,
  INDEX `sync_status`(`sync_status`) USING BTREE,
  INDEX `batch_code`(`batch_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 83037 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '资源同步明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_task_iaas_sync_lock
-- ----------------------------
DROP TABLE IF EXISTS `sys_task_iaas_sync_lock`;
CREATE TABLE `sys_task_iaas_sync_lock`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `res_pool_id` bigint(20) NOT NULL COMMENT '资源池ID',
  `res_id` bigint(20) NULL DEFAULT NULL COMMENT '资源ID',
  `lock_version` bigint(20) NULL DEFAULT NULL COMMENT '数据版本',
  `lock_status` int(11) NULL DEFAULT NULL COMMENT '任务状态，1：运行中，0：没有运行',
  `create_time` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `update_time` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `environment_id` bigint(20) NULL DEFAULT NULL COMMENT '云环境ID',
  `res_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源类型',
  `res_pool_type_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源池类型',
  `region_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '区域编码，项目CODE(Openstack体系)',
  `last_time` timestamp NULL DEFAULT NULL COMMENT '最后执行时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_res_pool_id_res_id`(`res_pool_id`, `res_id`, `tenant_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8560 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'iaas层资源同步' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_task_scene
-- ----------------------------
DROP TABLE IF EXISTS `sys_task_scene`;
CREATE TABLE `sys_task_scene`  (
  `task_scene_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '场景ID',
  `scene_type_id` int(11) NULL DEFAULT NULL COMMENT '分类ID',
  `task_scene_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '场景名称',
  `task_scene_desc` varchar(2000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '场景描述',
  `config_type` int(1) NULL DEFAULT NULL COMMENT '场景配置类型\n1:表单    2::路由',
  `config_content` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '场景配置内容',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `create_user` bigint(20) NULL DEFAULT NULL,
  `update_user` bigint(20) NULL DEFAULT NULL,
  `is_deleted` int(11) NULL DEFAULT 0 COMMENT '是否删除\n1：是\n0：否',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `os_type_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '操作系统类型id，逗号分隔',
  `status` int(2) NULL DEFAULT NULL COMMENT '状态',
  PRIMARY KEY (`task_scene_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '任务场景定义' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_task_scene_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_task_scene_type`;
CREATE TABLE `sys_task_scene_type`  (
  `scene_type_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `scene_type_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '分类名称',
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `create_user` bigint(20) NULL DEFAULT NULL,
  `update_user` bigint(20) NULL DEFAULT NULL,
  `is_deleted` int(11) NULL DEFAULT 0 COMMENT '是否删除\n1：是\n0：否',
  `tenant_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `status` int(2) NULL DEFAULT 0 COMMENT '状态',
  PRIMARY KEY (`scene_type_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '场景分类' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_vdc
-- ----------------------------
DROP TABLE IF EXISTS `sys_vdc`;
CREATE TABLE `sys_vdc`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门编号',
  `name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门名',
  `full_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门全称',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `parent_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父部门编号',
  `out_ref` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 566 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_vdc_20240830
-- ----------------------------
DROP TABLE IF EXISTS `sys_vdc_20240830`;
CREATE TABLE `sys_vdc_20240830`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门编号',
  `name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门名',
  `full_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门全称',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `parent_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父部门编号',
  `out_ref` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 255 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_vdc_20240902
-- ----------------------------
DROP TABLE IF EXISTS `sys_vdc_20240902`;
CREATE TABLE `sys_vdc_20240902`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门编号',
  `name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门名',
  `full_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门全称',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `parent_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父部门编号',
  `out_ref` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 272 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_vdc_azone_rel
-- ----------------------------
DROP TABLE IF EXISTS `sys_vdc_azone_rel`;
CREATE TABLE `sys_vdc_azone_rel`  (
  `id` int(11) NOT NULL,
  `vdc_code` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `azone_id` int(11) NULL DEFAULT NULL COMMENT '可用区ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_vdc_copy1
-- ----------------------------
DROP TABLE IF EXISTS `sys_vdc_copy1`;
CREATE TABLE `sys_vdc_copy1`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门编号',
  `name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门名',
  `full_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门全称',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `parent_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父部门编号',
  `out_ref` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 161 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_vdc_copy2
-- ----------------------------
DROP TABLE IF EXISTS `sys_vdc_copy2`;
CREATE TABLE `sys_vdc_copy2`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门编号',
  `name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门名',
  `full_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门全称',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `parent_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父部门编号',
  `out_ref` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 250 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_vdc_copy3
-- ----------------------------
DROP TABLE IF EXISTS `sys_vdc_copy3`;
CREATE TABLE `sys_vdc_copy3`  (
  `id` bigint(64) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门编号',
  `name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门名',
  `full_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '部门全称',
  `sort` int(11) NULL DEFAULT NULL COMMENT '排序',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `is_deleted` int(2) NULL DEFAULT 0 COMMENT '是否已删除',
  `parent_code` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '父部门编号',
  `out_ref` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '外部ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 272 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for t_model
-- ----------------------------
DROP TABLE IF EXISTS `t_model`;
CREATE TABLE `t_model`  (
  `model_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '模块ID',
  `model_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '模块编码',
  `model_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '模块名称',
  `model_endpoint` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '模块入口地址',
  `content_type` tinyint(4) NULL DEFAULT NULL COMMENT '0: simple   1:steups(步骤条)    2:tab页',
  `crt_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `crt_user_id` bigint(20) NULL DEFAULT NULL COMMENT '创建人',
  `last_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后修改时间',
  `last_user_id` bigint(20) NULL DEFAULT NULL COMMENT '最后修改人',
  `tenant_id` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  `project_version` int(11) NULL DEFAULT NULL COMMENT '当前版本',
  PRIMARY KEY (`model_id`) USING BTREE,
  UNIQUE INDEX `model_code`(`model_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '模块( MO中 这个叫服务)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for t_model_item
-- ----------------------------
DROP TABLE IF EXISTS `t_model_item`;
CREATE TABLE `t_model_item`  (
  `model_item_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '模块内容子项ID',
  `model_id` bigint(20) NULL DEFAULT NULL COMMENT '模块ID',
  `item_name` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '子项名称',
  `item_icon` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '子项icon',
  `item_content` mediumtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '模块内容',
  `show_order` int(11) NULL DEFAULT NULL COMMENT '展示顺序',
  `tenant_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '租户ID',
  PRIMARY KEY (`model_item_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '模块内容子项' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for t_monitor_lock
-- ----------------------------
DROP TABLE IF EXISTS `t_monitor_lock`;
CREATE TABLE `t_monitor_lock`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lock_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '锁定的编码值',
  `metric_code` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '指标编码',
  `endpoint` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '监控资源ID',
  `sname` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '策略名称',
  `crt_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `finish_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `content` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '告警内容',
  `status` int(11) NULL DEFAULT 0 COMMENT '处理状态 0:处理中   10:处理完成  -10:处理失败',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `lock_code_metric_code_endpoint`(`lock_code`, `metric_code`, `endpoint`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '监控报警唯一约束表(如：自动磁盘扩容)' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for testz01
-- ----------------------------
DROP TABLE IF EXISTS `testz01`;
CREATE TABLE `testz01`  (
  `c1` tinyint(255) NOT NULL,
  `c2` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  PRIMARY KEY (`c1`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for timer
-- ----------------------------
DROP TABLE IF EXISTS `timer`;
CREATE TABLE `timer`  (
  `key_` bigint(20) NOT NULL,
  `due_date_` bigint(20) NULL DEFAULT NULL,
  `element_instance_key_` bigint(20) NULL DEFAULT NULL,
  `process_definition_key_` bigint(20) NULL DEFAULT NULL,
  `process_instance_key_` bigint(20) NULL DEFAULT NULL,
  `repetitions` int(11) NULL DEFAULT NULL,
  `state_` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `target_element_id_` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `timestamp_` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`key_`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for variable
-- ----------------------------
DROP TABLE IF EXISTS `variable`;
CREATE TABLE `variable`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name_` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `partition_id_` int(11) NULL DEFAULT NULL,
  `position_` bigint(20) NULL DEFAULT NULL,
  `process_instance_key_` bigint(20) NULL DEFAULT NULL,
  `scope_key_` bigint(20) NULL DEFAULT NULL,
  `state_` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `timestamp_` bigint(20) NULL DEFAULT NULL,
  `value_` longtext CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = latin1 COLLATE = latin1_swedish_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- View structure for node_resource
-- ----------------------------
DROP VIEW IF EXISTS `node_resource`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `node_resource` AS select `kubeflow`.`node_resource`.`id` AS `id`,`kubeflow`.`node_resource`.`cluster_id` AS `res_pool_id`,`kubeflow`.`node_resource`.`node_name` AS `node_name`,`kubeflow`.`node_resource`.`resource` AS `resource`,`kubeflow`.`node_resource`.`created_on` AS `created_on`,`kubeflow`.`node_resource`.`changed_on` AS `changed_on` from `kubeflow`.`node_resource` order by `kubeflow`.`node_resource`.`changed_on` desc;

-- ----------------------------
-- Procedure structure for init_clear
-- ----------------------------
DROP PROCEDURE IF EXISTS `init_clear`;
delimiter ;;
CREATE PROCEDURE `init_clear`(IN p_tid VARCHAR(6))
BEGIN
DELETE FROM blade_tenant WHERE tenant_id = p_tid;
DELETE FROM `sys_vdc` WHERE tenant_id = p_tid;
DELETE FROM blade_user WHERE tenant_id = p_tid;
DELETE FROM sys_region WHERE tenant_id = p_tid;
DELETE FROM blade_role WHERE tenant_id = p_tid;
DELETE FROM sys_res_pool WHERE tenant_id = p_tid;
DELETE FROM sys_res_pool_vdc_ref WHERE tenant_id = p_tid;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for init_for_test4
-- ----------------------------
DROP PROCEDURE IF EXISTS `init_for_test4`;
delimiter ;;
CREATE PROCEDURE `init_for_test4`(IN p_tid VARCHAR(6))
BEGIN
DECLARE s_name varchar(255);
SET s_name = DATE_FORMAT(NOW(),'%m%d');
INSERT INTO blade_tenant(tenant_id, tenant_name, create_time, update_time, status, is_deleted) VALUE (p_tid, s_name, NOW(), NOW(), 1, 0);

SELECT rand_string(3) INTO @s_vdc_code;

INSERT INTO `sys_vdc`(tenant_id, `code`, `name`, `full_name`, `sort`, `is_deleted`, `parent_code`) VALUE (p_tid, @s_vdc_code, '演示组织', '演示组织', 1, 0, '0');

SELECT id INTO @s_dept_id FROM sys_vdc WHERE tenant_id = p_tid;

INSERT INTO `blade_user` (`tenant_id`, `code`, `account`, `password`, `name`, `real_name`, `avatar`, `email`, `phone`, `birthday`, `sex`, `role_id`, `dept_id`, `post_id`, `create_user`, `create_time`, `update_user`, `update_time`, `status`, `is_deleted`, `vdc_code`, `region_code`, `is_tenant`, `last_login_time`, `last_login_ip`) VALUES (p_tid, '', CONCAT(s_name,'_','admin'), '10470c3b4b1fed12c3baac014be15fac67c6e815', '租户管理员', '租户管理员', NULL, '', '', NULL, NULL, '1318107478500667393', @s_dept_id, NULL, 1402147202420420610, '2021-06-08 14:28:33', 1402147202420420610, '2021-06-08 14:28:33', 1, 0, @s_vdc_code, NULL, NULL, NULL, NULL);


SELECT rand_string(3) INTO @s_region_code;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (@s_region_code, '__root', @s_region_code, '0', '测试租户区域', '0', 0, 1, NULL, p_tid);

SELECT rand_string(3) INTO @s_region_code_os;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (CONCAT(@s_region_code,@s_region_code_os), 'openstack', '09Z09a', @s_region_code, 'OpenStack', '0,0001,000107', 1, 1, NULL, p_tid);

SELECT rand_string(3) INTO @s_region_code_hw;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (CONCAT(@s_region_code,@s_region_code_hw), 'hwcloud', '09Z09b', @s_region_code, '华为云', '0,0001,000107', 1, 2, NULL, p_tid);

SELECT rand_string(3) INTO @s_region_code_ali;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (CONCAT(@s_region_code,@s_region_code_ali), 'alicloud', '09Z09c', @s_region_code, '阿里云', '0,0001,000107', 1, 3, NULL, p_tid);

SELECT rand_string(3) INTO @s_region_code_tx;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (CONCAT(@s_region_code,@s_region_code_tx), 'txcloud', '09Z09d', @s_region_code, '腾讯云', '0,0001,000107', 1, 4, NULL, p_tid);

SELECT rand_string(3) INTO @s_region_code_vm;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (CONCAT(@s_region_code,@s_region_code_vm), 'vmware', '09Z09e', @s_region_code, 'VMware', '0,0001,000107', 1, 5, NULL, p_tid);

SELECT rand_string(3) INTO @s_region_code_mo;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (CONCAT(@s_region_code,@s_region_code_mo), 'managerone', '09Z09f', @s_region_code, 'ManageOne', '0,0001,000107', 1, 6, NULL, p_tid);

SELECT rand_string(3) INTO @s_region_code_hcs;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (CONCAT(@s_region_code,@s_region_code_hcs), 'hcs8.0', '09Z09g', @s_region_code, 'HCS8.0', '0,0001,000107', 1, 7, NULL, p_tid);

SELECT rand_string(3) INTO @s_region_code_ft;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (CONCAT(@s_region_code,@s_region_code_ft), 'ftcloud', '09Z09h', @s_region_code, '阿里小飞天', '0,0001,000107', 1, 8, NULL, p_tid);

SELECT rand_string(3) INTO @s_region_code_aps;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (CONCAT(@s_region_code,@s_region_code_aps), 'aliapsara', '09Z09i', @s_region_code, '阿里专有云', '0,0001,000107', 1, 9, NULL, p_tid);

SELECT rand_string(3) INTO @s_region_code_spec;
INSERT INTO `sys_region` (`code`, `res_pool_type_code`, `out_region_code`, `parent_code`, `name`, `ancestors`, `level`, `sort`, `remark`, `tenant_id`) VALUES (CONCAT(@s_region_code,@s_region_code_spec), 'spec1.0', '09Z09j', @s_region_code, '标准接入1.0', '0,0001,000107', 1, 10, NULL, p_tid);



INSERT INTO `blade_role` (`appid`, `tenant_id`, `parent_id`, `role_name`, `sort`, `role_alias`, `is_global`, `is_deleted`, `is_system`) VALUES (NULL, p_tid, 0, '训练管理角色', 1, 'tran-role', NULL, 0, 0);
INSERT INTO `blade_role` (`appid`, `tenant_id`, `parent_id`, `role_name`, `sort`, `role_alias`, `is_global`, `is_deleted`, `is_system`) VALUES (NULL, p_tid, 0, '技术保障员', 1, 'tech-role', NULL, 0, 0);
INSERT INTO `blade_role` (`appid`, `tenant_id`, `parent_id`, `role_name`, `sort`, `role_alias`, `is_global`, `is_deleted`, `is_system`) VALUES (NULL, p_tid, 0, '仿真应用开发', 3, 'dev-role', NULL, 0, 0);

SELECT id INTO @s_role_tran FROM blade_role WHERE tenant_id = p_tid AND role_alias = 'tran-role';
SELECT id INTO @s_role_tech FROM blade_role WHERE tenant_id = p_tid AND role_alias = 'tech-role';
SELECT id INTO @s_role_dev FROM blade_role WHERE tenant_id = p_tid AND role_alias = 'dev-role';

insert into blade_role_menu(menu_id, role_id) VALUE(9,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(12,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1333269206485319682,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1341635371242872833,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(8,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962202,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962203,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962204,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962205,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962206,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962207,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1164798754318962202,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1308209335113875458,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1311593058589040642,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1312586636404563969,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1312587224689254402,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1313848975762210818,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1313849425848778754,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058709345,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727075,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727123,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727234,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727257,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727426,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727456,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727763,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1319532324219432961,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1368821285765980162,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675217,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675218,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675252,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675253,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675254,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675255,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675266,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675267,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675268,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675269,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675270,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1291565205764009986,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1291565908075048961,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1291692240725454849,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1316922217543450625,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1316931606576766977,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1342399331898081281,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1342403103189745665,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1342403386514980865,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1342404059738521601,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1346389786314690561,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1346390955124609026,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1346391415189426177,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351330122670010369,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351330383354392578,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351757989790773250,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351791182447276033,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(2,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1303298292242833409,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1303299257150857217,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1303605964298096642,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1304327883704086530,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1306068789749600257,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1306076070973263873,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1306120350819405826,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1306142017167806465,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1323468373619077122,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1316936330852048898,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(3,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1293138585856323585,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1315997029590700033,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1316931982122164225,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1316932647712071681,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1316932884581195712,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1316932884581195723,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1316932884581195777,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1316933703493885953,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(123309903445091356,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(123560763550932312,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(130382235224283343,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1333618276114624514,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(131693387589236095,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1316933875892363266,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1318119324108566529,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1331606739988471810,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1333389116058238978,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1333389366114254849,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1331923391988871170,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1331924109432958977,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1331940736094416897,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1341289682650521602,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351341481780551681,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351341481780551682,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351341643395473410,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351341798517612545,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351341926359998466,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351342133311152129,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351342259744251905,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1351342373896429570,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1341635371242872834,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(6,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(130329829136730356,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675204,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675223,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675224,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675225,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675226,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675227,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675228,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675208,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675241,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675242,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675243,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675244,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675209,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675245,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675246,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675247,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675248,@s_role_tran);
insert into blade_role_menu(menu_id, role_id) VALUE(1341635778094555138,@s_role_tran);

insert into blade_role_menu(menu_id, role_id) VALUE(9,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(12,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1341635371242872833,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(8,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962202,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962203,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962204,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962205,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962206,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1164733399668962207,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1164798754318962202,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1308209335113875458,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1311593058589040642,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1312586636404563969,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1312587224689254402,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1313848975762210818,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1313849425848778754,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058709345,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727075,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727123,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727234,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727257,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727426,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727456,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1313923474058727763,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1319532324219432961,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1368821285765980162,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675217,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675218,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675252,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675253,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675254,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675255,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675266,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675267,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675268,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675269,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1123598815738675270,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1291565205764009986,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1291565908075048961,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1291692240725454849,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1316922217543450625,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1316931606576766977,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1342399331898081281,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1342403103189745665,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1342403386514980865,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1342404059738521601,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1346389786314690561,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1346390955124609026,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1346391415189426177,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351330122670010369,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351330383354392578,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351757989790773250,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351791182447276033,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(2,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1303298292242833409,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1303299257150857217,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1303605964298096642,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1304327883704086530,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1306068789749600257,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1306076070973263873,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1306120350819405826,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1306142017167806465,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1323468373619077122,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1316936330852048898,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(3,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1293138585856323585,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1315997029590700033,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1316931982122164225,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1316932647712071681,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1316932884581195712,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1316932884581195723,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1316932884581195777,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1316933703493885953,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(123309903445091356,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(123560763550932312,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(130382235224283343,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1333618276114624514,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(131693387589236095,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1316933875892363266,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1318119324108566529,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1331606739988471810,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1333389116058238978,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1333389366114254849,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1331923391988871170,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1331924109432958977,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1331940736094416897,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1341289682650521602,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351341481780551681,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351341481780551682,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351341643395473410,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351341798517612545,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351341926359998466,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351342133311152129,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351342259744251905,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1351342373896429570,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1341637084477644801,@s_role_tech);
insert into blade_role_menu(menu_id, role_id) VALUE(1397384364001603585,@s_role_tech);


insert into blade_role_menu(menu_id, role_id) VALUE(1341635371242872833,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1342399331898081281,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1342403103189745665,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1342403386514980865,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1342404059738521601,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1346389786314690561,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1346390955124609026,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1346391415189426177,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1351791182447276033,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1341637084477644801,@s_role_dev);
insert into blade_role_menu(menu_id, role_id) VALUE(1397384364001603585,@s_role_dev);



INSERT INTO `sys_vdc` (`tenant_id`, `code`, `name`, `full_name`, `sort`, `remark`, `is_deleted`, `parent_code`) VALUES (p_tid, CONCAT(@s_vdc_code,'01a'), '技术保障中心', '技术保障中心', 1, NULL, 0, @s_vdc_code);
INSERT INTO `sys_vdc` (`tenant_id`, `code`, `name`, `full_name`, `sort`, `remark`, `is_deleted`, `parent_code`) VALUES (p_tid, CONCAT(@s_vdc_code,'01a01b'), '基地1', '基地1', 1, NULL, 0, CONCAT(@s_vdc_code,'01a'));
INSERT INTO `sys_vdc` (`tenant_id`, `code`, `name`, `full_name`, `sort`, `remark`, `is_deleted`, `parent_code`) VALUES (p_tid, CONCAT(@s_vdc_code,'01a01c'), '基地2', '基地2', 1, NULL, 0, CONCAT(@s_vdc_code,'01a'));
INSERT INTO `sys_vdc` (`tenant_id`, `code`, `name`, `full_name`, `sort`, `remark`, `is_deleted`, `parent_code`) VALUES (p_tid, CONCAT(@s_vdc_code,'01a01b01d'), '基地1子组织', '基地1子组织', 1, NULL, 0, CONCAT(@s_vdc_code,'01a01b'));

SELECT id,code INTO @s_dept_tech_id, @s_dept_tech_code  FROM sys_vdc WHERE tenant_id = p_tid AND code = CONCAT(@s_vdc_code,'01a');
SELECT id,code INTO @s_dept_dev1_id, @s_dept_dev1_code FROM sys_vdc WHERE tenant_id = p_tid AND code = CONCAT(@s_vdc_code,'01a01b');
SELECT id,code INTO @s_dept_dev2_id, @s_dept_dev2_code FROM sys_vdc WHERE tenant_id = p_tid AND code = CONCAT(@s_vdc_code,'01a01c');
SELECT id,code INTO @s_dept_dev_c_id, @s_dept_devc_code FROM sys_vdc WHERE tenant_id = p_tid AND code = CONCAT(@s_vdc_code,'01a01b01d');

INSERT INTO `blade_user` (`tenant_id`, `code`, `account`, `password`, `name`, `real_name`, `avatar`, `email`, `phone`, `birthday`, `sex`, `role_id`, `dept_id`, `post_id`, `create_user`, `create_time`, `update_user`, `update_time`, `status`, `is_deleted`, `vdc_code`, `region_code`, `is_tenant`, `last_login_time`, `last_login_ip`) VALUES (p_tid, '', 'trainmgr', 'e672275a4f24e44e6e94def3fc6045c429992e60', 'trainmgr', 'trainmgr', NULL, '', '', NULL, NULL, @s_role_tran, @s_dept_tech_id, NULL, 1401704911499149313, '2021-06-07 09:20:45', 1401704911499149313, '2021-06-07 09:20:45', 1, 0, @s_dept_tech_code, NULL, NULL, NULL, NULL);

INSERT INTO `blade_user` (`tenant_id`, `code`, `account`, `password`, `name`, `real_name`, `avatar`, `email`, `phone`, `birthday`, `sex`, `role_id`, `dept_id`, `post_id`, `create_user`, `create_time`, `update_user`, `update_time`, `status`, `is_deleted`, `vdc_code`, `region_code`, `is_tenant`, `last_login_time`, `last_login_ip`) VALUES (p_tid, '', 'tech', '9ac53109413275fcc852c73502a701a8c4abaa17', 'tech', 'tech', NULL, '', '', NULL, NULL, @s_role_tech, @s_dept_tech_id, NULL, 1401704911499149313, '2021-06-07 09:21:30', 1401704911499149313, '2021-06-07 09:21:30', 1, 0, @s_dept_tech_code, NULL, NULL, NULL, NULL);

INSERT INTO `blade_user` (`tenant_id`, `code`, `account`, `password`, `name`, `real_name`, `avatar`, `email`, `phone`, `birthday`, `sex`, `role_id`, `dept_id`, `post_id`, `create_user`, `create_time`, `update_user`, `update_time`, `status`, `is_deleted`, `vdc_code`, `region_code`, `is_tenant`, `last_login_time`, `last_login_ip`) VALUES (p_tid, '', 'tech1', '71c2ccd3e4ade127073149984eaca72516ca7d87', 'tech1', 'tech1', NULL, '', '', NULL, NULL, @s_role_tech, @s_dept_dev1_id, NULL, 1401704911499149313, '2021-06-07 09:24:04', 1401704911499149313, '2021-06-07 09:24:04', 1, 0,@s_dept_dev1_code, NULL, NULL, NULL, NULL);

INSERT INTO `blade_user` (`tenant_id`, `code`, `account`, `password`, `name`, `real_name`, `avatar`, `email`, `phone`, `birthday`, `sex`, `role_id`, `dept_id`, `post_id`, `create_user`, `create_time`, `update_user`, `update_time`, `status`, `is_deleted`, `vdc_code`, `region_code`, `is_tenant`, `last_login_time`, `last_login_ip`) VALUES (p_tid, '', 'dev', '78977826ab260d2b41895aea75a5a1b27c8a79e5', 'dev', 'dev', NULL, '', '', NULL, NULL, @s_role_dev, @s_dept_dev2_id, NULL, 1401704911499149313, '2021-06-07 09:24:30', 1401704911499149313, '2021-06-07 09:24:30', 1, 0, @s_dept_dev2_code, NULL, NULL, NULL, NULL);

END
;;
delimiter ;

-- ----------------------------
-- Function structure for rand_string
-- ----------------------------
DROP FUNCTION IF EXISTS `rand_string`;
delimiter ;;
CREATE FUNCTION `rand_string`(n INT)
 RETURNS varchar(255) CHARSET utf8
BEGIN
    DECLARE chars_str varchar(100) DEFAULT 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    DECLARE return_str varchar(255) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    WHILE i < n DO
        SET return_str = concat(return_str,substring(chars_str , FLOOR(1 + RAND()*62 ),1));
        SET i = i +1;
    END WHILE;
    RETURN return_str;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for sync_users
-- ----------------------------
DROP PROCEDURE IF EXISTS `sync_users`;
delimiter ;;
CREATE PROCEDURE `sync_users`()
BEGIN

			START TRANSACTION;

			INSERT INTO blade.blade_user (tenant_id, code, account, password, name, real_name, avatar, email, phone, birthday,
																		sex, role_id, dept_id, post_id, create_user, create_time, update_user, update_time,
																		status, is_deleted, vdc_code, region_code, is_tenant, last_login_time, last_login_ip,
																		is_black_user, is_used, is_first_login, login_count, fail_login_count, org, out_ref)
			SELECT 
					'888888' AS tenant_id,
					'' AS code,
					su.sys_user_code AS account,
					'848045a2c2b0c21b5f0da2ab68c514af26b5ab5c' AS password,
					su.sys_user_code AS name,
					su.sys_user_code AS real_name,
					NULL AS avatar,
					'' AS email,
					'' AS phone,
					NULL AS birthday,
					NULL AS sex,
					'1734863057562652673,1912344289895895043' AS role_id,
					'124' AS dept_id,
					NULL AS post_id,
					NULL AS create_user,
					NOW() AS create_time,
					NULL AS update_user,
					NOW() AS update_time,
					1 AS status,
					0 AS is_deleted,
					'020' AS vdc_code,
					NULL AS region_code,
					NULL AS is_tenant,
					NOW() AS last_login_time,
					'127.0.0.1' AS last_login_ip,
					NULL AS is_black_user,
					NULL AS is_used,
					0 AS is_first_login,
					NULL AS login_count,
					NULL AS fail_login_count,
					NULL AS org,
					su.sys_user_code AS out_ref
			FROM `bee-esmp`.system_user su
			LEFT JOIN blade.blade_user bu ON bu.out_ref = su.sys_user_code
			WHERE bu.id IS NULL;

			COMMIT;

			SELECT '用户同步完成' AS message;

	END
;;
delimiter ;

-- ----------------------------
-- Event structure for HANDLER_ROLE_STATUS
-- ----------------------------
DROP EVENT IF EXISTS `HANDLER_ROLE_STATUS`;
delimiter ;;
CREATE EVENT `HANDLER_ROLE_STATUS`
ON SCHEDULE
EVERY '600' SECOND STARTS '2022-06-07 17:16:03'
ON COMPLETION PRESERVE
DO UPDATE service_runtime_app_role u,(
	SELECT
		srar.id 
	FROM
		service_runtime_app_role srar,
		service_runtime_app_version srav 
	WHERE
		srav.deployment_type = 'pc' 
		AND srav.id = srar.version_id 
		AND srar.update_at < now() - INTERVAL 20 MINUTE 
		AND srar.STATUS LIKE '%ing' 
		AND srar.STATUS != 'pending' 
		AND srar.delete_at = 0 
		AND srav.delete_at = 0 
	) r 
	SET u.STATUS = 'partDeploy' 
WHERE
	u.id = r.id
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
