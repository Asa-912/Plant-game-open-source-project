-- Asa 植物游戏数据库玩法扩展
-- 数据库：PostgreSQL
-- 用途：在已有基础数据库上增加玩法字段、数据表及省内排行榜视图。
-- 本文件依据提供的 SQL 整理，删除 PDF 页脚并统一格式，保留原有结构与查询逻辑。
--
-- 运行前提：
--   1. 已存在 users、estate_plant、upload、biome_map、species、contribution_ledger。
--   2. 被引用表的 id 字段为可被外键引用的 uuid 字段。
--   3. users 已有 username；contribution_ledger 已有 player_id、delta。
--   4. 数据库可调用 gen_random_uuid()。
--   5. 本文件新增的字段、表和视图尚不存在；不支持重复执行。
--
-- 设计待确认：
--   professional_observation 相关引用待同步；仅注释标识的引用未设置外键。
--   province_leaderboard 保留按省份和用户名分组的原始逻辑，
--   若同省用户允许重名，其贡献分会被合并，后续应考虑按用户 id 分组。
--   本文件未在项目实际数据库中执行验证，不包含基础建库及应用层玩法逻辑。

-- 01 用户与庄园植物扩展

ALTER TABLE users
    ADD COLUMN reputation numeric(12,2) NOT NULL DEFAULT 0,
    ADD COLUMN collection_permission varchar(64),
    ADD COLUMN province varchar(64);

ALTER TABLE estate_plant
    ADD COLUMN is_cultivar boolean NOT NULL DEFAULT false,
    ADD COLUMN derived_traits jsonb,
    ADD COLUMN current_season varchar(64),
    ADD COLUMN disease_status varchar(64),
    ADD COLUMN fruit_efficiency numeric(5,2);

-- 02 队伍与生态活动

CREATE TABLE team (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    leader_id uuid NOT NULL REFERENCES users(id),
    name varchar(64) NOT NULL,
    status varchar(32) NOT NULL DEFAULT 'open',
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE eco_event (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    map_id uuid REFERENCES biome_map(id),
    name varchar(64) NOT NULL,
    description text,
    start_at timestamptz,
    end_at timestamptz,
    recurrence jsonb,
    is_active boolean NOT NULL DEFAULT true
);

ALTER TABLE upload
    ADD COLUMN event_id uuid REFERENCES eco_event(id),
    ADD COLUMN team_id uuid REFERENCES team(id);

-- 03 科研归档与百科

CREATE TABLE scientific_archive (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    observation_id uuid, -- 匿名引用 professional_observation（待同步）
    archived_at timestamptz NOT NULL DEFAULT now(),
    is_public boolean NOT NULL DEFAULT false
);

CREATE TABLE encyclopedia_entry (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    species_id uuid REFERENCES species(id),
    normal_image_ref uuid, -- upload_id（仅注释，未设置外键）
    pro_specimen_ref uuid, -- professional_observation_id（待同步）
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 04 育种与玩家增益

CREATE TABLE breeding_record (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    parent1_id uuid REFERENCES estate_plant(id),
    parent2_id uuid REFERENCES estate_plant(id),
    species1_id uuid REFERENCES species(id),
    species2_id uuid REFERENCES species(id),
    offspring_id uuid REFERENCES estate_plant(id),
    bred_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE player_buff (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    buff_type varchar(64) NOT NULL,
    value numeric(5,2),
    valid_until timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 05 声望与审核

CREATE TABLE reputation_ledger (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id uuid NOT NULL REFERENCES users(id),
    delta numeric(12,2) NOT NULL DEFAULT 0,
    type varchar(64),
    related_id uuid,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE review_record (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id uuid REFERENCES users(id), -- 系统审核为 NULL
    target_type varchar(32) NOT NULL, -- 'professional_observation'（待同步）
    target_id uuid NOT NULL,
    score numeric(3,2),
    comment text,
    status varchar(32) NOT NULL DEFAULT 'pending',
    reviewed_at timestamptz
);

-- 06 挑战任务与玩家进度

CREATE TABLE challenge_quest (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(128) NOT NULL,
    description text,
    target_taxon varchar(64),
    required_scope varchar(128),
    reward_title varchar(128),
    reward_buff varchar(128),
    is_active boolean NOT NULL DEFAULT true
);

CREATE TABLE quest_progress (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    quest_id uuid NOT NULL REFERENCES challenge_quest(id),
    user_id uuid NOT NULL REFERENCES users(id),
    completed_items jsonb,
    status varchar(32) NOT NULL DEFAULT 'in_progress',
    completed_at timestamptz
);

-- 07 活动植物与季节周期

CREATE TABLE event_spawn (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id uuid NOT NULL REFERENCES eco_event(id),
    species_id uuid REFERENCES species(id),
    rarity smallint CHECK (rarity BETWEEN 1 AND 5),
    spawn_window jsonb,
    is_active boolean NOT NULL DEFAULT true
);

CREATE TABLE season_cycle (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    map_id uuid REFERENCES biome_map(id),
    season_name varchar(64) NOT NULL,
    cycle jsonb,
    fruit_multiplier numeric(5,2) DEFAULT 1.00
);

-- 08 队伍成员与社区

CREATE TABLE team_member (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id uuid NOT NULL REFERENCES team(id),
    user_id uuid NOT NULL REFERENCES users(id),
    role varchar(32) NOT NULL DEFAULT 'member',
    joined_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE community (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(64) NOT NULL,
    founder_id uuid NOT NULL REFERENCES users(id),
    level_required int,
    reputation_required numeric(12,2),
    reputation numeric(12,2) NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE community_member (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id uuid NOT NULL REFERENCES community(id),
    user_id uuid NOT NULL REFERENCES users(id),
    role varchar(32) NOT NULL DEFAULT 'member',
    reputation_contribution numeric(12,2) NOT NULL DEFAULT 0,
    joined_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE community_garden (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id uuid NOT NULL REFERENCES community(id),
    design_config jsonb,
    reputation numeric(12,2) NOT NULL DEFAULT 0,
    level int NOT NULL DEFAULT 1
);

-- 09 标本馆与展示

CREATE TABLE specimen_hall (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    name varchar(64),
    is_public boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE specimen_display (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    hall_id uuid NOT NULL REFERENCES specimen_hall(id),
    plant_id uuid NOT NULL, -- estate_plant / upload（未设置外键）
    is_professional boolean NOT NULL DEFAULT false,
    display_config jsonb,
    arranged_at timestamptz NOT NULL DEFAULT now()
);

-- 10 省内贡献排行榜
-- 贡献分来源为 contribution_ledger.delta，而非 users.reputation。

CREATE VIEW province_leaderboard AS
SELECT
    u.province,
    u.username,
    SUM(cl.delta) AS total_points,
    RANK() OVER (
        PARTITION BY u.province
        ORDER BY SUM(cl.delta) DESC
    ) AS rank
FROM contribution_ledger cl
JOIN users u ON u.id = cl.player_id
WHERE u.province IS NOT NULL
GROUP BY u.province, u.username;
