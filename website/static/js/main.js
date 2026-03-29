/**
 * TerraSpan Website - Pure HTML/CSS/JS
 * Main JavaScript file for interactivity
 */

// DOM Elements
const form = document.getElementById('contact-form');
const formStatus = document.getElementById('form-status');

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    initializeNavigation();
    initializeContactForm();
    addSmoothScrolling();
});

/**
 * Initialize navigation
 */
function initializeNavigation() {
    const navLinks = document.querySelectorAll('.nav-links a');
    
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            // Check if it's an external link
            if (this.host !== window.location.host) {
                return;
            }
            
            // Update active state
            navLinks.forEach(l => l.style.borderBottom = 'none');
            this.style.borderBottom = '3px solid var(--primary)';
        });
    });

    // Set active link on page load
    const currentPath = window.location.pathname;
    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href === currentPath || (currentPath === '/' && href === '/')) {
            link.style.borderBottom = '3px solid var(--primary)';
        }
    });
}

/**
 * Initialize contact form
 */
function initializeContactForm() {
    if (!form) return;

    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Get form data
        const name = document.getElementById('name').value;
        const email = document.getElementById('email').value;
        const subject = document.getElementById('subject').value;
        const message = document.getElementById('message').value;
        
        // Validate form
        if (!name || !email || !subject || !message) {
            showFormError('Please fill in all fields');
            return;
        }
        
        if (!isValidEmail(email)) {
            showFormError('Please enter a valid email address');
            return;
        }
        
        // Simulate form submission
        showFormStatus('Sending...', 'info');
        
        // In a real application, you would send this to a backend
        setTimeout(() => {
            showFormStatus('Message sent successfully! We\'ll get back to you soon.', 'success');
            form.reset();
            
            // Clear status after 5 seconds
            setTimeout(() => {
                formStatus.style.display = 'none';
            }, 5000);
        }, 1500);
    });
}

/**
 * Add smooth scrolling to anchor links
 */
function addSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href === '#') return;
            
            e.preventDefault();
            const target = document.querySelector(href);
            
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

/**
 * Validate email address
 */
function isValidEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

/**
 * Show form status message
 */
function showFormStatus(message, type) {
    if (!formStatus) return;
    
    formStatus.textContent = message;
    formStatus.style.display = 'block';
    formStatus.className = '';
    
    if (type === 'success') {
        formStatus.style.background = '#d4edda';
        formStatus.style.color = '#155724';
        formStatus.style.border = '1px solid #c3e6cb';
    } else if (type === 'error') {
        formStatus.style.background = '#f8d7da';
        formStatus.style.color = '#721c24';
        formStatus.style.border = '1px solid #f5c6cb';
    } else if (type === 'info') {
        formStatus.style.background = '#d1ecf1';
        formStatus.style.color = '#0c5460';
        formStatus.style.border = '1px solid #bee5eb';
    }
}

/**
 * Show form error
 */
function showFormError(message) {
    showFormStatus(message, 'error');
}

/**
 * Mobile menu toggle (if needed in future)
 */
function toggleMobileMenu() {
    const navLinks = document.querySelector('.nav-links');
    if (navLinks) {
        navLinks.style.display = navLinks.style.display === 'none' ? 'flex' : 'none';
    }
}

/**
 * Dark mode detection and handling
 */
function handleDarkMode() {
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    if (prefersDark) {
        document.documentElement.style.colorScheme = 'dark';
    }
}

// Handle dark mode on load
handleDarkMode();

// Listen for color scheme changes
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', handleDarkMode);

/**
 * Helpful utility functions
 */

/**
 * Track page views (for analytics)
 */
function trackPageView(pageName) {
    if (window.gtag) {
        gtag('event', 'page_view', {
            'page_title': pageName,
            'page_path': window.location.pathname
        });
    }
}

/**
 * Log errors for debugging
 */
window.addEventListener('error', function(event) {
    console.error('Error:', event.message, event.filename, event.lineno);
});

/**
 * Console logging helper (development only)
 */
if (!window.location.hostname.includes('production')) {
    console.log('TerraSpan Website - Development Mode');
    console.log('🌐 Multi-Cloud Infrastructure Management');
}
