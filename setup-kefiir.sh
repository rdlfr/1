#!/bin/bash
set -e

RED='\033[0;31m'
GRY='\033[0;90m'
NC='\033[0m'
BLD='\033[1m'

echo -e "${RED}${BLD}"
echo "  ██╗  ██╗███████╗███████╗██╗██╗██╗██████╗ "
echo "  ██║ ██╔╝██╔════╝██╔════╝██║██║██║██╔══██╗"
echo "  █████╔╝ █████╗  █████╗  ██║██║██║██████╔╝"
echo "  ██╔═██╗ ██╔══╝  ██╔══╝  ██║██║██║██╔══██╗"
echo "  ██║  ██╗███████╗██║     ██║██║██║██║  ██║"
echo "  ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝╚═╝╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${GRY}  // установка блог-платформы на Strapi${NC}"
echo ""

# --- 1. Создание структуры ---
echo -e "${RED}[1/5]${NC} Создание директорий..."
mkdir -p /opt/kefiir/frontend
cd /opt/kefiir

# --- 2. Strapi ---
echo -e "${RED}[2/5]${NC} Установка Strapi CMS (это займёт 2-3 минуты)..."
if [ ! -d "/opt/kefiir/cms" ]; then
  npx create-strapi-app@latest cms \
    --quickstart \
    --no-run \
    --dbclient=sqlite \
    --dbfilename=.tmp/data.db
else
  echo -e "${GRY}  → /opt/kefiir/cms уже существует, пропускаем${NC}"
fi

# --- 3. Build Strapi ---
echo -e "${RED}[3/5]${NC} Сборка Strapi admin-панели..."
cd /opt/kefiir/cms
npm run build
cd /opt/kefiir

# --- 4. Фронтенд ---
echo -e "${RED}[4/5]${NC} Создание фронтенда..."

python3 << 'PYEOF'
html = """<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>KEFIIR — блог</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Oswald:wght@400;700&display=swap" rel="stylesheet">
<style>
  :root {
    --bg:       #161616;
    --bg2:      #1e1e1e;
    --bg3:      #252525;
    --border:   #2e2e2e;
    --border2:  #3a3a3a;
    --text:     #c2c2c2;
    --text2:    #888;
    --text3:    #555;
    --red:      #8B1A1A;
    --red2:     #a32020;
    --red3:     #6b1414;
    --mono:     'Share Tech Mono', monospace;
    --display:  'Oswald', sans-serif;
  }

  * { margin: 0; padding: 0; box-sizing: border-box; }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: var(--mono);
    font-size: 14px;
    line-height: 1.6;
    min-height: 100vh;
  }

  /* ── ШАПКА ── */
  header {
    background: #0f0f0f;
    border-bottom: 2px solid var(--red3);
    padding: 0 24px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 64px;
    position: sticky;
    top: 0;
    z-index: 100;
  }

  .logo-wrap {
    display: flex;
    align-items: baseline;
    gap: 12px;
  }

  .logo {
    font-family: var(--display);
    font-size: 32px;
    font-weight: 700;
    color: var(--red);
    letter-spacing: 6px;
    text-shadow:
      0 0 30px rgba(139,26,26,0.6),
      0 0 60px rgba(139,26,26,0.2);
    user-select: none;
  }

  .logo-slash {
    color: var(--text3);
    font-size: 13px;
    letter-spacing: 1px;
  }

  .header-meta {
    color: var(--text3);
    font-size: 11px;
    text-align: right;
  }

  /* ── НАВ ── */
  nav {
    background: var(--bg2);
    border-bottom: 1px solid var(--border);
    padding: 0 24px;
    display: flex;
    gap: 0;
  }

  nav a {
    color: var(--text2);
    text-decoration: none;
    font-size: 12px;
    letter-spacing: 1px;
    padding: 10px 16px;
    border-right: 1px solid var(--border);
    transition: all 0.15s;
    text-transform: uppercase;
  }

  nav a:first-child { border-left: 1px solid var(--border); }
  nav a:hover { color: var(--red); background: var(--bg3); }
  nav a.active { color: var(--red); border-bottom: 2px solid var(--red); }

  /* ── КОНТЕЙНЕР ── */
  .wrap {
    max-width: 980px;
    margin: 0 auto;
    padding: 28px 20px;
    display: grid;
    grid-template-columns: 1fr 240px;
    gap: 24px;
  }

  @media (max-width: 700px) {
    .wrap { grid-template-columns: 1fr; }
    .sidebar { display: none; }
  }

  /* ── ПОСТЫ ── */
  .section-label {
    font-size: 10px;
    letter-spacing: 3px;
    color: var(--text3);
    text-transform: uppercase;
    margin-bottom: 14px;
    padding-bottom: 6px;
    border-bottom: 1px solid var(--border);
  }

  .post-card {
    background: var(--bg2);
    border: 1px solid var(--border);
    border-left: 3px solid var(--red3);
    margin-bottom: 12px;
    padding: 14px 16px;
    transition: all 0.15s;
    cursor: pointer;
  }

  .post-card:hover {
    border-left-color: var(--red2);
    background: var(--bg3);
    transform: translateX(2px);
  }

  .post-num {
    color: var(--text3);
    font-size: 10px;
    margin-bottom: 4px;
  }

  .post-num span { color: var(--red); }

  .post-title {
    font-family: var(--display);
    font-size: 17px;
    font-weight: 400;
    color: #ddd;
    margin-bottom: 6px;
    letter-spacing: 0.5px;
  }

  .post-title a {
    color: inherit;
    text-decoration: none;
  }

  .post-title a:hover { color: var(--red2); }

  .post-excerpt {
    color: var(--text2);
    font-size: 12px;
    line-height: 1.7;
    margin-bottom: 10px;
  }

  .post-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .post-date {
    color: var(--text3);
    font-size: 11px;
  }

  .post-tags {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
  }

  .tag {
    background: var(--bg);
    border: 1px solid var(--border2);
    color: var(--text3);
    font-size: 10px;
    padding: 1px 7px;
    letter-spacing: 0.5px;
  }

  .tag:hover { border-color: var(--red3); color: var(--red); }

  /* ── САЙДБАР ── */
  .sidebar {}

  .widget {
    background: var(--bg2);
    border: 1px solid var(--border);
    margin-bottom: 16px;
    padding: 14px;
  }

  .widget-title {
    font-size: 10px;
    letter-spacing: 3px;
    color: var(--text3);
    text-transform: uppercase;
    margin-bottom: 12px;
    padding-bottom: 6px;
    border-bottom: 1px solid var(--border);
  }

  .widget-item {
    color: var(--text2);
    font-size: 12px;
    padding: 5px 0;
    border-bottom: 1px solid var(--border);
    cursor: pointer;
    display: flex;
    justify-content: space-between;
  }

  .widget-item:last-child { border-bottom: none; }
  .widget-item:hover { color: var(--red); }

  .widget-count {
    color: var(--text3);
    font-size: 10px;
  }

  .status-line {
    background: #0a0a0a;
    border: 1px solid var(--border);
    padding: 8px 12px;
    font-size: 10px;
    color: var(--text3);
    letter-spacing: 1px;
  }

  .status-line .ok { color: #2d7a2d; }
  .status-line .err { color: var(--red); }

  /* ── СОСТОЯНИЯ ── */
  .state-msg {
    text-align: center;
    padding: 60px 20px;
    color: var(--text3);
    font-size: 13px;
    letter-spacing: 1px;
  }

  .state-msg .icon { font-size: 24px; margin-bottom: 12px; }

  /* ── ФУТЕР ── */
  footer {
    border-top: 1px solid var(--border);
    padding: 16px 24px;
    text-align: center;
    color: var(--text3);
    font-size: 11px;
    letter-spacing: 1px;
    margin-top: 20px;
  }

  footer span { color: var(--red3); }

  /* ── СКРОЛЛ ── */
  ::-webkit-scrollbar { width: 4px; }
  ::-webkit-scrollbar-track { background: var(--bg); }
  ::-webkit-scrollbar-thumb { background: var(--red3); }

  /* ── АНИМАЦИЯ ЗАГРУЗКИ ── */
  @keyframes blink {
    0%, 100% { opacity: 1; }
    50% { opacity: 0; }
  }

  .cursor {
    display: inline-block;
    width: 8px;
    height: 14px;
    background: var(--red);
    animation: blink 1s step-end infinite;
    vertical-align: middle;
    margin-left: 4px;
  }
</style>
</head>
<body>

<header>
  <div class="logo-wrap">
    <div class="logo">KEFIIR</div>
    <div class="logo-slash">// блог</div>
  </div>
  <div class="header-meta" id="hdr-meta">загрузка<span class="cursor"></span></div>
</header>

<nav>
  <a href="/" class="active">ГЛАВНАЯ</a>
  <a href="/merch.html">МЁРЧ</a>
  <a href="/about.html">О НАС</a>
</nav>

<div class="wrap">
  <main>
    <div class="section-label">// последние публикации</div>
    <div id="posts">
      <div class="state-msg"><div class="icon">░</div>загрузка постов<span class="cursor"></span></div>
    </div>
  </main>

  <aside class="sidebar">
    <div class="status-line" id="api-status">API: <span class="cursor">░</span></div>
    <br>
    <div class="widget">
      <div class="widget-title">// категории</div>
      <div id="cats">
        <div class="widget-item" style="color:var(--text3)">загрузка...</div>
      </div>
    </div>
    <div class="widget">
      <div class="widget-title">// статистика</div>
      <div class="widget-item">
        <span>публикаций</span>
        <span class="widget-count" id="cnt-posts">—</span>
      </div>
      <div class="widget-item">
        <span>статус</span>
        <span class="widget-count ok" id="cnt-status">offline</span>
      </div>
    </div>
  </aside>
</div>

<footer>
  <span>KEFIIR</span> — работает на Strapi &amp; Node.js · <span id="yr"></span>
</footer>

<script>
const API = window.location.hostname === 'localhost'
  ? 'http://localhost:1337/api'
  : '/api';

document.getElementById('yr').textContent = new Date().getFullYear();

function fmtDate(iso) {
  return new Date(iso).toLocaleString('ru', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  });
}

async function loadPosts() {
  try {
    const r = await fetch(`${API}/articles?populate=*&sort=publishedAt:desc&pagination[pageSize]=20`);
    if (!r.ok) throw new Error(r.status);
    const { data, meta } = await r.json();

    document.getElementById('api-status').innerHTML = 'API: <span class="ok">online ✓</span>';
    document.getElementById('cnt-status').textContent = 'online';
    document.getElementById('hdr-meta').textContent = `${meta?.pagination?.total || 0} публикаций`;

    if (!data || data.length === 0) {
      document.getElementById('posts').innerHTML = `
        <div class="state-msg">
          <div class="icon">▓</div>
          постов пока нет — добавь через <a href="/admin" style="color:var(--red)">admin-панель</a>
        </div>`;
      document.getElementById('cnt-posts').textContent = '0';
      return;
    }

    document.getElementById('cnt-posts').textContent = meta?.pagination?.total || data.length;

    document.getElementById('posts').innerHTML = data.map((p, i) => {
      const a = p.attributes || p;
      const title   = a.title || 'Без названия';
      const content = a.content || a.description || '';
      const excerpt = content.replace(/<[^>]*>/g, '').substring(0, 180);
      const date    = a.publishedAt || a.createdAt || '';
      const cats    = a.categories?.data || [];

      return `
        <div class="post-card" onclick="location.href='/post.html?id=${p.id}'">
          <div class="post-num">№<span>${String(i + 1).padStart(4, '0')}</span> · id:${p.id}</div>
          <div class="post-title"><a href="/post.html?id=${p.id}">${title}</a></div>
          ${excerpt ? `<div class="post-excerpt">${excerpt}${content.length > 180 ? '...' : ''}</div>` : ''}
          <div class="post-footer">
            <div class="post-date">${date ? fmtDate(date) : ''}</div>
            <div class="post-tags">
              ${cats.map(c => `<span class="tag">${c.attributes?.name || c.name}</span>`).join('')}
            </div>
          </div>
        </div>`;
    }).join('');

  } catch (e) {
    document.getElementById('api-status').innerHTML = 'API: <span class="err">offline ✗</span>';
    document.getElementById('cnt-status').textContent = 'offline';
    document.getElementById('hdr-meta').textContent = 'Strapi не отвечает';
    document.getElementById('posts').innerHTML = `
      <div class="state-msg">
        <div class="icon">▒</div>
        не удалось подключиться к Strapi<br>
        <span style="font-size:11px;color:var(--text3)">убедись что strapi запущен на порту 1337</span>
      </div>`;
  }
}

async function loadCategories() {
  try {
    const r = await fetch(`${API}/categories?pagination[pageSize]=10`);
    const { data } = await r.json();
    if (!data || data.length === 0) {
      document.getElementById('cats').innerHTML =
        '<div class="widget-item" style="color:var(--text3)">категорий нет</div>';
      return;
    }
    document.getElementById('cats').innerHTML = data.map(c => {
      const name = c.attributes?.name || c.name || '—';
      return `<div class="widget-item">
        <span>${name}</span>
        <span class="widget-count">→</span>
      </div>`;
    }).join('');
  } catch {}
}

loadPosts();
loadCategories();
</script>
</body>
</html>"""

with open('/opt/kefiir/frontend/index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print("  → frontend/index.html создан")
PYEOF

# --- 5. PM2 ---
echo -e "${RED}[5/5]${NC} Запуск через PM2..."

pm2 describe kefiir-cms > /dev/null 2>&1 && pm2 delete kefiir-cms || true

pm2 start npm \
  --name "kefiir-cms" \
  --cwd /opt/kefiir/cms \
  -- run start

pm2 save

echo ""
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  KEFIIR установлен${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Strapi admin  →  ${BLD}http://ВАШ_IP:1337/admin${NC}"
echo -e "  Фронтенд      →  ${BLD}/opt/kefiir/frontend/index.html${NC}"
echo -e "  PM2 статус    →  ${BLD}pm2 status${NC}"
echo ""
echo -e "${GRY}  Следующий шаг: настрой Apache/nginx для фронтенда${NC}"
echo -e "${GRY}  и добавь content-type 'Article' в Strapi admin${NC}"
echo ""
