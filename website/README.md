# TerraSpan Website

A high-performance, responsive static website showcasing the TerraSpan multi-cloud infrastructure project. Built with Hugo for simplicity and speed.

## Overview

The TerraSpan website is built with **Hugo**, a modern static site generator that provides:

- ⚡ **Blazing Fast**: Generates sites in milliseconds
- 📱 **Responsive Design**: Mobile-first, works on all devices
- 🎨 **Easy Customization**: Simple template structure
- 🔍 **SEO Friendly**: Built-in sitemap and structured data
- 🚀 **CDN Ready**: Optimized static assets

## Directory Structure

```
website/
├── archetypes/              # Content templates
├── config.toml              # Hugo configuration
├── content/                 # Page content (markdown)
│   ├── _index.md           # Home page
│   ├── features.md         # Features page
│   ├── docs/               # Documentation
│   ├── blog/               # Blog posts
│   └── contact.md          # Contact page
├── data/                   # Data files (YAML, TOML, JSON)
├── layouts/                # HTML templates
│   ├── _default/          # Default layouts
│   ├── partials/          # Reusable components
│   └── shortcodes/        # Custom shortcodes
├── public/                # Generated output (don't commit)
├── static/                # Static files
│   ├── css/              # Stylesheets
│   ├── js/               # JavaScript
│   └── img/              # Images
├── themes/                # Hugo themes
└── README.md              # This file
```

## Installation

### Prerequisites

- Hugo >= 0.120.0
- Git
- (Optional) Node.js for asset building

### Setup

1. **Install Hugo**
   ```bash
   # macOS
   brew install hugo
   
   # Windows
   choco install hugo-extended
   
   # Linux
   sudo apt-get install hugo
   ```

2. **Navigate to website directory**
   ```bash
   cd website
   ```

3. **Run local development server**
   ```bash
   hugo server -D
   ```

   Visit http://localhost:1313 to see the site

## Content Management

### Creating Pages

1. **Create new page**
   ```bash
   hugo new posts/my-new-post.md
   ```

2. **Edit page in markdown**
   ```markdown
   ---
   title: "Post Title"
   date: 2026-03-29
   draft: false
   categories: ["feature"]
   tags: ["terraform", "cloud"]
   ---
   
   Post content here...
   ```

3. **View in browser**
   Server auto-reloads on file changes

### Front Matter

Each page has front matter (YAML between `---` markers):

```yaml
title: "Page Title"
description: "Short description for SEO"
date: 2026-03-29T10:00:00Z
draft: false                    # Set to false to publish
categories: ["category"]
tags: ["tag1", "tag2"]
author: "Author Name"
featured: false                 # Show on home page
image: "/img/cover.jpg"        # Featured image
---
```

### Content Organization

```
content/
├── _index.md              # Home page (/)
├── about.md               # About page
├── features.md            # Features page
├── blog/
│   ├── _index.md         # Blog main page
│   ├── first-post.md
│   └── second-post.md
├── docs/
│   ├── _index.md         # Docs home
│   ├── getting-started/
│   │   └── index.md
│   └── guide/
└── contact.md             # Contact page
```

## Customization

### Configuration

Edit `config.toml` for site-wide settings:

```toml
baseURL = "https://terraspan.dev/"
title = "TerraSpan"
languageCode = "en-us"

[outputs]
  home = ["HTML", "JSON"]

[params]
  description = "Multi-cloud infrastructure with Terraform"
  author = "TerraSpan Team"
  
  [params.social]
    github = "https://github.com/terraspan"
    linkedin = "https://linkedin.com/company/terraspan"
```

### Styling

Modify CSS in `static/css/`:

```css
/* static/css/style.css */
:root {
  --primary: #0066cc;
  --secondary: #00cc66;
  --font-size: 16px;
}

body {
  font-family: 'Segoe UI', sans-serif;
  color: var(--text-color);
}
```

### Themes

Install and customize Hugo themes:

```bash
# Add theme as git submodule
git submodule add https://github.com/theme/name.git themes/name

# Update config.toml
echo 'theme = "name"' >> config.toml
```

Popular themes:
- [Hugo Ananke](https://themes.gohugo.io/themes/gohugoioTheme/)
- [Hugo Paper](https://themes.gohugo.io/themes/hugo-paper/)
- [Hugo Blox](https://themes.gohugo.io/themes/hugo-blox-builder/)

## Building

### Development Build

```bash
hugo server -D
# Includes draft content
# Auto-reload on changes
# Runs on http://localhost:1313
```

### Production Build

```bash
hugo
# Generates optimized output to public/
# Includes only published content
```

### Build with Environment Variables

```bash
HUGO_ENV=production hugo
```

## Deployment

### GitHub Pages

1. **Configure in config.toml**
   ```toml
   baseURL = "https://your-username.github.io/terraspan/"
   ```

2. **Deploy GitHub Actions**
   Create `.github/workflows/hugo.yml`

3. **Push to repository**
   ```bash
   git add .
   git commit -m "Update website"
   git push origin main
   ```

### Netlify

1. **Create Netlify account**
2. **Connect GitHub repository**
3. **Set build command**: `hugo`
4. **Set publish directory**: `public`
5. **Deploy** on every push to main

### AWS S3 + CloudFront

```bash
# Build site
hugo

# Sync to S3
aws s3 sync public/ s3://terraspan-website/ --delete

# Invalidate CloudFront
aws cloudfront create-invalidation --distribution-id <ID> --paths "/*"
```

### Azure Static Web Apps

```bash
# Create static web app
az staticwebapp create \
  --name terraspan-website \
  --resource-group terraspan-rg \
  --source https://github.com/your-org/terraspan

# Deploy
az staticwebapp deploy --name terraspan-website
```

## Performance Optimization

### Image Optimization

Use Hugo's image processing:

```markdown
{{< img src="image.jpg" alt="Description" width="600" height="400" >}}
```

### Minification

Enable in config.toml:

```toml
[minify]
  minifyJSON = true
  minifyCSS = true
  minifyJS = true
  minifyHTML = true
```

### Caching

Add cache control headers:

```toml
[[outputs.html]]
  path = "index.html"
  
[caching]
  [caching.images]
    max_age = 31536000  # 1 year
```

## SEO

### Search Engine Optimization

Add to config.toml:

```toml
[outputs]
  home = ["HTML", "JSON", "RSS"]
  
[sitemap]
  changefreq = "weekly"
  priority = 0.5
```

### Structured Data

Add JSON-LD:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "TerraSpan",
  "url": "https://terraspan.dev",
  "description": "Multi-cloud infrastructure management"
}
</script>
```

## Monitoring

### Analytics

Add Google Analytics:

```html
<!-- layouts/partials/footer.html -->
{{ template "_internal/google_analytics.html" . }}
```

Configure in config.toml:

```toml
[params]
  googleAnalytics = "G-XXXXXXXXXX"
```

### Uptime Monitoring

Monitor site health:
- Pingdom / UptimeRobot
- Google Cloud Monitoring
- Azure Monitor

## Troubleshooting

### Build Errors

```bash
# Clear cache
rm -rf resources/_gen/

# Rebuild
hugo --gc
```

### Content Not Appearing

1. Check `draft` status (should be `false`)
2. Verify date is not in future
3. Check file location in `content/`
4. Run with `-D` flag for drafts

### Performance Issues

1. Optimize images
2. Minify CSS/JS
3. Enable caching headers
4. Use CDN for static assets

## Related Documentation

- [Hugo Documentation](https://gohugo.io/documentation/)
- [Hugo Best Practices](https://gohugo.io/getting-started/quick-start/)
- [TerraSpan Main README](../../README.md)
- [Deployment Guide](../../docs/deployment.md)

## License

Website content is part of TerraSpan project under Apache 2.0 license.
