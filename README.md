# Rohit — Full Stack & AI Developer Portfolio

A stunning, award-worthy portfolio website built with pure HTML, CSS, and JavaScript featuring:

- 🎬 **Scroll-driven video animation** — 240 cinematic frames synced to scroll position
- 🌊 **Liquid glass UI** — frosted navbar, glassmorphism cards, and smooth animations
- 🔐 **Admin Control Center** — login-protected dashboard for managing messages & projects  
- 🤖 **AI-powered resilience** — particle fallback animation if frames aren't loaded
- 📱 **Fully responsive** — works on all screen sizes
- ⚡ **GitHub Pages ready** — 100% static, no backend required

## 🚀 Deploy to GitHub Pages

### Step 1 — Push to GitHub

```bash
git init
git add .
git commit -m "Initial portfolio deployment"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

### Step 2 — Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages** (in the left sidebar)
3. Under **Source**, select **Deploy from a branch**
4. Set Branch to `main` and folder to `/ (root)`
5. Click **Save**

Your site will be live at: `https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/`

> ⚠️ **Note:** Initial deployment may take 2–5 minutes. The scroll animation frames (~180MB) will be served directly from GitHub's CDN.

## 🔐 Admin Login

Access the admin dashboard at `/admin.html`

> Credentials are private and known only to the site owner.

The admin panel works 100% offline using `localStorage` — messages from the contact form are stored locally and visible in the admin dashboard immediately.

## 🏗️ Project Structure

```
webu/
├── index.html              # Main portfolio page
├── admin.html              # Admin control center  
├── 404.html                # GitHub Pages redirect
├── .nojekyll               # Disables Jekyll (required for GitHub Pages)
├── assets/
│   ├── logo.svg            # Horizontal wordmark logo
│   ├── logo-icon.svg       # Icon-only logo (favicon)
│   ├── rohit-photo.jpg     # Profile photo
│   └── projects/           # Project thumbnail images
├── video_frames_30fps/     # 240 PNG frames for scroll animation
│   ├── frame_000000.png
│   └── ...
└── data/
    └── messages.json       # Contact form storage (local server)
```

## 🎨 Design System

- **Colors:** `#E85D25` (orange), `#0A0A0A` (dark background)
- **Fonts:** Bebas Neue (headings), Oswald (subheadings), Inter (body)
- **Animation:** CSS `@keyframes` + IntersectionObserver for scroll reveals
- **Cards:** Glassmorphism with `backdrop-filter: blur()`
