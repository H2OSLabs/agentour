#!/bin/bash
set -e

# 生成认证系统
mix phx.gen.auth Accounts User users

# 生成 Agent 模型
mix phx.gen.context Agents Agent agents \
    name:string \
    type:string \
    status:string \
    user_id:references:users \
    config:map

# 生成 Session 模型
mix phx.gen.context Sessions Session sessions \
    name:string \
    status:string \
    owner_id:references:users

# 生成 Participant 模型（Session 参与者）
mix phx.gen.context Sessions Participant participants \
    session_id:references:sessions \
    agent_id:references:agents \
    role:string

# 生成 Artifact 模型
mix phx.gen.context Artifacts Artifact artifacts \
    name:string \
    type:string \
    content:text \
    session_id:references:sessions \
    creator_id:references:agents

# 生成 Version 模型（Artifact 版本）
mix phx.gen.context Artifacts Version versions \
    artifact_id:references:artifacts \
    content:text \
    version:integer \
    creator_id:references:agents

# 生成 Plugin 模型
mix phx.gen.context Plugins Plugin plugins \
    name:string \
    type:string \
    status:string \
    config:map

# 运行数据库迁移
mix ecto.migrate 