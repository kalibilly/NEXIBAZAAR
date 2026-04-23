/* ===== CART MANAGEMENT ===== */

/**
 * Get cart from localStorage
 */
function getCart() {
    const cart = localStorage.getItem('cart');
    return cart ? JSON.parse(cart) : [];
}

/**
 * Save cart to localStorage
 */
function saveCart(cart) {
    localStorage.setItem('cart', JSON.stringify(cart));
}

/**
 * Add item to cart
 */
function addToCart(productId, productName, productPrice) {
    let cart = getCart();
    
    // Check if product already in cart
    const existingItem = cart.find(item => item.id === productId);
    
    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        cart.push({
            id: productId,
            name: productName,
            price: productPrice,
            quantity: 1
        });
    }
    
    saveCart(cart);
    updateCartBadge();
    alert(`${productName} added to cart!`);
}

/**
 * Remove item from cart
 */
function removeFromCart(productId) {
    let cart = getCart();
    cart = cart.filter(item => item.id !== productId);
    saveCart(cart);
    updateCartBadge();
}

/**
 * Clear cart
 */
function clearCart() {
    localStorage.removeItem('cart');
    updateCartBadge();
}

/**
 * Update cart badge count
 */
function updateCartBadge() {
    const cart = getCart();
    const badge = document.getElementById('cartBadge');
    if (badge) {
        badge.textContent = cart.length;
    }
}

/* ===== AUTHENTICATION ===== */

/**
 * Get auth token from localStorage
 */
function getToken() {
    return localStorage.getItem('token');
}

/**
 * Get current user from localStorage
 */
function getUser() {
    const user = localStorage.getItem('user');
    return user ? JSON.parse(user) : null;
}

/**
 * Check if user is logged in
 */
function isLoggedIn() {
    // consider either token existence or server-side session
    const tokenPresent = !!getToken();
    const server = window.serverAuth === true;
    return tokenPresent || server;
}

/**
 * Logout function
 */
function logout() {
    logoutUser().finally(() => {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        updateAuthUI();
        // also clear server session by visiting logout endpoint
        window.location.href = '/logout';
    });
}

/**
 * Update UI based on authentication state
 */
function updateAuthUI() {
    const isAuth = isLoggedIn();
    const loginLink = document.getElementById('loginLink');
    const registerLink = document.getElementById('registerLink');
    const logoutLink = document.getElementById('logoutLink');
    const profileLink = document.getElementById('profileLink');
    const ordersLink = document.getElementById('ordersLink');

    if (loginLink) loginLink.style.display = isAuth ? 'none' : 'block';
    if (registerLink) registerLink.style.display = isAuth ? 'none' : 'block';
    if (logoutLink) logoutLink.style.display = isAuth ? 'block' : 'none';
    if (profileLink) profileLink.style.display = isAuth ? 'block' : 'none';
    if (ordersLink) ordersLink.style.display = isAuth ? 'block' : 'none';
}

/**
 * Setup user menu dropdown
 */
function setupUserMenu() {
    const userBtn = document.getElementById('userBtn');
    const userDropdown = document.getElementById('userDropdown');

    if (userBtn && userDropdown) {
        userBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            userDropdown.classList.toggle('show');
        });

        document.addEventListener('click', function(e) {
            if (!userDropdown.contains(e.target) && !userBtn.contains(e.target)) {
                userDropdown.classList.remove('show');
            }
        });
    }
}

/* ===== THEME HANDLING ===== */
function applyTheme(theme) {
    document.body.classList.remove('light-mode', 'dark-mode');
    document.body.classList.add(theme + '-mode');
    localStorage.setItem('theme', theme);
}

function toggleTheme() {
    const current = localStorage.getItem('theme') || 'light';
    const next = current === 'light' ? 'dark' : 'light';
    applyTheme(next);
    // update button icon if desired
}

function setupThemeToggle() {
    const btn = document.getElementById('themeToggle');
    if (btn) {
        btn.addEventListener('click', toggleTheme);
    }
    // initialize from storage
    const stored = localStorage.getItem('theme') || 'light';
    applyTheme(stored);
}

/* ===== INITIALIZATION ===== */
document.addEventListener('DOMContentLoaded', function() {
    // Update cart badge
    updateCartBadge();
    
    // Update auth UI
    updateAuthUI();
    
    // Setup user menu
    setupUserMenu();
    
    // Theme
    setupThemeToggle();
});
