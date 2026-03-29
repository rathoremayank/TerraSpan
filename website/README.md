# TerraSpan Website

A high-performance, responsive static website showcasing the TerraSpan multi-cloud infrastructure project. Built with pure HTML, CSS, and JavaScript—**no dependencies required**.

## Overview

The TerraSpan website is built with vanilla **HTML, CSS, and JavaScript**, providing:

- ⚡ **Zero Dependencies**: Pure HTML/CSS/JS—no build tools required
- 🚀 **Blazing Fast**: Minimal JavaScript, pure static delivery
- 📱 **Responsive Design**: Mobile-first, adaptive CSS with dark mode support
- 🎨 **Easy Customization**: Simple, readable HTML structure with inline styles
- 🔍 **SEO Friendly**: Semantic HTML, proper meta tags, and structured data
- 🌍 **Universal Compatibility**: Works everywhere—browsers, servers, CDNs

## Directory Structure

```
website/
├── static/
│   ├── index.html           # Home page
│   ├── features.html        # Features page
│   ├── docs.html            # Documentation page
│   ├── blog.html            # Blog page
│   ├── contact.html         # Contact page
│   ├── css/
│   │   └── style.css        # Main stylesheet (responsive, dark mode)
│   ├── js/
│   │   └── main.js          # Interactive features (form handling, navigation)
│   └── img/                 # Images directory (for future assets)
├── config.toml              # (Deprecated - kept for reference only)
├── content/                 # (Deprecated - markdown files no longer needed)
├── themes/                  # (Deprecated - Hugo themes no longer used)
└── README.md                # This file
```

**Note**: The `config.toml`, `content/`, and `themes/` directories are retained for reference but are no longer used in the pure HTML/CSS/JS architecture.

## Installation

### Prerequisites
Quick Start

### Prerequisites

- Any modern web browser
- A simple HTTP server (for local development)
- Git (optional, for version control)

### Local Development

Choose any of these options to serve the website locally:

**Option 1: Python (Built-in)**
```bash
cd website/static
python -m http.server 8000
```
Visit http://localhost:8000

**Option 2: Node.js (npx)**
```bash
cd website/static
npx http-server
```
Visit http://localhost:8080

**Option 3: PHP (Built-in)**
```bash
cd website/static
php -S localhost:8000
```
Visit http://localhost:8000

**Option 4: LNew Pages

1. **Create a new HTML file** in `website/static/`:
   ```bash
   # Example: creating a new page called "about.html"
   touch website/static/about.html
   ```

2. **Copy the structure from an existing page**:
   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>Page Title - TerraSpan</title>
       <meta name="description" content="Page description for SEO">
       <link rel="stylesheet" href="/css/style.css">
   </head>
   <body>
       <!-- Navigation (copy from index.html) -->
       <nav class="navbar">
           <!-- ... -->
       </nav>

       <!-- Your content -->
       <section style="padding: 60px 0;">
           <div class="container">
               <h1>Page Title</h1>
               <p>Your content here...</p>
           </div>
       </section>

       <!-- Footer (copy from index.html) -->
       <footer>
           <!-- ... -->
       </footer>

       <script src="/js/main.js"></script>
   </body>
   </html>
   ```

3. **Update navigation links** in all HTML files to reference the new page:
   ```html
   <li><a href="/about.html">About</a></li>
   ```

### Page Template Best Practices

- Use semantic HTML (`<header>`, `<main>`, `<section>`, `<footer>`)
- Include proper meta tags for SEO in `<head>`
- Use CSS variables for consistent styling
- Keep structure consistent across all pages
- Always include the navigation bar and footer
- Load `main.js` at the end of `<body>─ docs/
│   ├── _index.md         # Docs home
│   ├── getting-started/
│   │   └── index.md
│   └── guide/
└── contact.md             # Contact page
```Styling

All styling is in `static/css/style.css`. Key customization points:

**Change Color Scheme (CSS Variables)**:
```css
:root {
    --primary: #0066cc;        /* Main brand color */
    --secondary: #00cc66;      /* Accent color */
    --accent: #ff6600;         /* Highlight color */
    --dark: #1a1a1a;           /* Dark background */
    --light: #f5f5f5;          /* Light background */
    --text: #333;              /* Text color */
    --text-light: #666;        /* Light text */
    --border: #ddd;            /* Border color */
    --shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* Dark mode colors (auto-applies when system prefers dark mode) */
@media (prefers-color-scheme: dark) {
    :root {
        --dark: #ffffff;
        --light: #1a1a1a;
        --text: #f5f5f5;
        --text-light: #ccc;
        --border: #444;
    }
}
```

**Customize Typography**:
```css
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    font-size: 16px;
    line-height: 1.6;
}

h1, h2, h3 { font-weight: 700; }
```

### JavaScript Enhancements

Main interactivity is in `static/js/main.js`:

- **Form Validation**: Contact form validation and submission
- **Navigation**: Active link highlighting
- **Smooth Scrolling**: Anchor link animation
- **Dark Mode Detection**: Automatic color scheme detection
- **Error Handling**: Console error logging

To add more interactivity:
1. Create a new function in `main.js`
2. Call it from the `DOMContentLoaded` event
3. Test thoroughly in all browsers
Popular themes:
- [Hugo Ananke](https://themes.gohugo.io/themes/gohugoioTheme/)
- [Hugo Paper](https://themes.gohugo.io/themes/hugo-paper/)
- [Hugo Blox](https://themes.gohugo.io/themes/hugo-blox-builder/)

## Building

###File Optimization

### Minification (Optional)

For production, optimize file sizes:

**CSS Minification**:
```bash
# Using csso-cli
npm install -g csso-cli
csso static/css/style.css -o static/css/style.min.css
```

**JavaScript Minification**:
```bash
# Using terser
npm install -g terser
terser static/js/main.js -o static/js/main.min.js
```

Then update HTML files to reference `.min.css` and `.min.js` files.

### Image Optimization

```bash
# Using ImageMagick
mogrify -quality 85 static/img/*.jpg
The GitHub Actions workflow (`.github/workflows/deploy-pages.yml`) automatically deploys the website:

1. **Enable GitHub Pages** in repository settings:
   - Settings → Pages → Source: GitHub Actions

2. **Website is deployed** automatically on push to `main` with changes inside `website/static/`

3. **Access** your site at `https://your-username.github.io`

For custom domain:
```bash
# Add CNAME file in website/static/
echo "yourdomain.com" > website/static/CNAME
```

### Netlify

1. Create Netlify account and connect GitHub repo
2. Configure build settings:
   - Build command: (leave empty)
   - Publish directory: `website/static`
3. Deploy on every push

### AWS S3 + CloudFront

```bash
# Sync to S3
aws s3 sync website/static/ s3://terraspan-website/ --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id <ID> --paths "/*"
```

### Azure Static Web Apps

```bash
# Create static web app
az staticwebapp create \
  --name terraspan-website \
  --resource-group terraspan-rg \
  --source https://github.com/your-org/terraspan \
  --output-location "website/static"
```

### Simple HTTP Server

For testing or small deployments:
```bash
# Quick deployment to any server with HTTP
scp -r website/static/* user@server:/var/www/html/
# Create static web app
az sCaching Headers

Configure your server to set cache headers:

**Nginx**:
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 365d;
    add_header Cache-Control "public, immutable";
}

location ~* \.html$ {
    expires 1h;
    add_header Cache-Control "public, must-revalidate";
}
```

**Apache**:
```apache
<FilesMatch "\.js$|\.css$|\.jpg$|\.png$|\.gif$">
    Header set Cache-Control "max-age=31536000, public, immutable"
</FilesMatch>

<FilesMatch "\.html$">
    Header set Cache-Control "max-age=3600, public, must-revalidate"
</FilesMatch>
```

### Performance Tips

- ✅ All CSS is in a single file (no multiple requests)
- ✅ Minimal JavaScript (only ~300 lines)
- ✅ No external dependencies or CDN calls
- ✅ Re Best Practices

### Meta Tags

Every page should include:
```html
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Title - TerraSpan</title>
    <meta name="description" content="Brief description under 160 characters">
    <meta name="keywords" content="terraform, cloud, infrastructure">
    <meta name="author" content="TerraSpan Team">
    <meta property="og:title" content="Page Title">
    <meta property="og:description" content="Description for social sharing">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://terraspan.dev/page">
</head>
```

### Structured Data

Add JSON-LD to `<head>`:
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "TerraSpan",
  "url": "https://terraspan.dev",
  "logo": "https://terraspan.dev/logo.png",
  "description": "Production-grade multi-cloud infrastructure provisioning with Terraform",
  "sameAs": [
    "https://github.com/your-org/terraspan",
    "https://twitter.com/terraspan"
  ]
}
</script>
```
Analytics & Monitoring

### Google Analytics

Add to every HTML page before closing `</body>`:
```html
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

### Uptime Monitoring

Service options:
- [Pingdom](https://www.pingdom.com/)
- [UptimeRobot](https://uptimerobot.com/)
- [Google Cloud Monitoring](https://cloud.google.com/stackdriver)
- [Azure Monitor](https://azure.microsoft.com/en-us/services/monitor/)
- [Datadog](https://www.datadoghq.com/)

### Real User Monitoring

Add simple RUM tracking:
```jPages Not Loading

1. **Check file paths**: Ensure HTML files are in `website/static/`
2. **Verify links**: Navigation links should use `.html` extension
3. **Check CSS paths**: Should be `/css/style.css` (absolute path)
4. **Clear browser cache**: Hard refresh with Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)

### Form Not Working

1. Check browser console for JavaScript errors
2. Verify form names match in `contact.html` and `main.js`
3. Contact form currently shows success message (client-side)
4. For email submission, integrate backend service:
   - [Formspree](https://formspree.io/)
   - [getform.io](https://getform.io/)
   - [Basin](https://usebasin.com/)

### Styling Issues

1. Check CSS paths in HTML `<head>`
2. Verify CSS variables are defined in `:root`
3. Clear browser cache
4. Check browser DevTools for CSS conflicts
5. Test in incognito mode

### Dark Mode Not Working

1. Check `@media (prefers-color-scheme: dark)` in CSS
2. Test in browser's dark mode (DevTools → Rendering → Emulate CSS Media Feature)
3. TerraSpan Main README](../../README.md)
- [Deployment Guide](../../docs/deployment.md)
- [Contributing Guidelines](../../CONTRIBUTING.md)
- [Architecture Guide](../../docs/architecture.md)
- [CI/CD Workflows](../../.github/workflows/README.md)

## Resources

- [MDN Web Docs](https://developer.mozilla.org/)
- [CSS Tricks](https://css-tricks.com/)
- [JavaScript Info](https://javascript.info/)
- [Web Performance Guide](https://web.dev/performance/)
- [SEO Starter Guide](https://developers.google.com/search/docs
1. **GitHub Pages not showing changes**: Clear gh-pages branch cache
2. **Custom domain not working**: Verify CNAME file in `website/static/`
3. **Mixed content error (HTTP/HTTPS)**: Ensure all resource URLs use HTTPS
4. **404 errors**: Check file extensions (must use `.html` or configure server redirects)
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
