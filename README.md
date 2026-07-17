# Gentle Hotkeys

选中文本后按快捷键，把原文替换成润色版、译文或简短总结。  
云端 provider 可以在安装时选择：OpenRouter Qwen、DeepSeek 官方，或者只用本地 Ollama。

Gentle Hotkeys is a small hotkey tool for polishing blunt messages, translating Chinese/English text, and summarizing long chat logs with OpenRouter and Ollama fallback.

## 快捷键

Windows：

- `Ctrl+Alt+G`：礼貌但不背锅地润色
- `Ctrl+Alt+V`：中英互译
- `Ctrl+Alt+M`：简化/总结，把一大段聊天记录压缩成两三句话
- `Ctrl+Alt+Shift+Q`：退出

macOS：

- `Command+Option+G`：礼貌但不背锅地润色
- `Command+Option+V`：中英互译
- `Command+Option+M`：简化/总结，把一大段聊天记录压缩成两三句话
- `Command+Option+Shift+Q`：退出

按下热键后会有一声很短的提示音，表示工具已经接住了快捷键。OpenRouter 首次请求可能需要几秒；如果云端超时，会继续降级到免费模型或本地 Ollama。

## 一键安装

Windows：

1. 解压整个文件夹。
2. 双击 `install_windows.cmd`。
3. 如果系统拦截脚本，右键选择“以管理员身份运行”或允许执行。

macOS：

1. 解压整个文件夹。
2. 在终端运行：

```bash
cd /path/to/gentle-hotkeys
chmod +x install_macos.command run_macos.command setup_venv.sh
./install_macos.command
```

macOS 第一次使用全局热键时，可能需要授权：

```text
System Settings > Privacy & Security > Accessibility
```

把 Terminal、iTerm 或 Python 加进去并允许。

安装脚本会做这些事：

- 创建本目录专用 `.venv`
- 安装 Python 依赖
- 可选选择云端 provider，并保存对应 API key 到本地 `.openrouter_key` 或 `.deepseek_key`
- 检查/尝试安装 Ollama
- 启动 Ollama 服务
- 拉取 `qwen2.5:3b`
- 注册开机自启动
- 启动热键工具

## 手动运行

Windows：

```powershell
.\run.ps1
```

macOS：

```bash
./run_macos.command
```

## 测试模型

Windows：

```powershell
.\run.ps1 --test polish "你今天必须把这个东西搞定 不然就弄死你"
.\run.ps1 --test translate "发下你的参数"
.\run.ps1 --test summarize "A: 今天要修登录 bug。B: 我下午处理。A: 明天上线，风险比较高。B: 修完会同步。"
```

macOS：

```bash
./run_macos.command --test polish "你今天必须把这个东西搞定 不然就弄死你"
./run_macos.command --test translate "发下你的参数"
./run_macos.command --test summarize "A: 今天要修登录 bug。B: 我下午处理。A: 明天上线，风险比较高。B: 修完会同步。"
```

## 自定义

编辑 `config.json`。

云端 provider：

```json
{
  "cloud": {
    "provider": "openrouter-qwen"
  }
}
```

可选值：

- `openrouter-qwen`：OpenRouter Qwen3.5 Flash -> OpenRouter free -> Ollama
- `deepseek-official`：DeepSeek 官方 deepseek-v4-flash -> Ollama
- `ollama`：只用本地 Ollama

OpenRouter 配置：

```json
{
  "openrouter": {
    "primary_model": "qwen/qwen3.5-flash-02-23",
    "free_model": "openrouter/free",
    "timeout_seconds": 12
  },
  "deepseek": {
    "model": "deepseek-v4-flash"
  },
  "ollama": {
    "model": "qwen2.5:3b"
  }
}
```

配置 API key：

```text
.openrouter_key
.deepseek_key
```

也可以设置环境变量：

```text
OPENROUTER_API_KEY
DEEPSEEK_API_KEY
```

安装脚本会按 provider 提示输入对应 key，并保存到本地私密文件。不配置 key 时会跳过云端，直接使用本地 Ollama。

换模型：

```json
{
  "ollama": {
    "model": "qwen2.5:7b-instruct-q4_K_M"
  }
}
```

更省内存：

```json
{
  "ollama": {
    "keep_alive": 0
  }
}
```

默认是 `"30s"`，停用后很快释放显存/内存。`0` 是每次生成后立刻卸载，最省但下一次会慢一点。

改快捷键：

```json
{
  "hotkeys": {
    "windows": {
      "polish": "ctrl+alt+g",
      "translate": "ctrl+alt+v",
      "summarize": "ctrl+alt+m",
      "quit": "ctrl+alt+shift+q"
    },
    "macos": {
      "polish": "cmd+alt+g",
      "translate": "cmd+alt+v",
      "summarize": "cmd+alt+m",
      "quit": "cmd+alt+shift+q"
    }
  }
}
```

## 设计说明

- 润色风格是“礼貌、清楚、合作但不卑微”，不会在原文没有责任归属时替自己认错。
- 翻译会把选中文本放进 `<text>` 隔离区，所以“发下你的参数”会被翻译，而不是被模型当成命令回答。
- 总结会把聊天记录压缩成两到三句话，优先保留结论、待办、责任人、时间点和风险。
- 润色会先识别原文意图，催办/威胁类句子会降火成明确期限和优先级，不会乱跳成“环境排查”。
- 含明显暴力威胁的催办句会走本地确定性改写兜底，避免小模型脑补后果或吐出标签。
- Provider 可选 OpenRouter Qwen 或 DeepSeek 官方；云端失败会自动降级到本地 Ollama。
- Windows 使用 `keyboard` 后端监听热键；macOS 使用 `pynput` 后端，需要辅助功能权限。

## 开机自启动

安装脚本会自动配置。

手动添加：

Windows：

```powershell
.\run.ps1 --install-startup
```

macOS：

```bash
./run_macos.command --install-startup
```

手动移除：

Windows：

```powershell
.\run.ps1 --uninstall-startup
```

macOS：

```bash
./run_macos.command --uninstall-startup
```

## 日志

日志在当前目录：

```text
gentle_hotkeys.log
```

## License

MIT
