/* ===== API CLIENT FUNCTIONS ===== */

/**
 * Generic API fetch function
 */
async function apiCall(endpoint, options = {}) {
    const url = `${API_BASE_URL}${endpoint}`;
    const token = getToken();

    const headers = {
        'Content-Type': 'application/json',
        ...options.headers
    };

    if (token && options.authenticated !== false) {
        headers['Authorization'] = `Token ${token}`;
    }

    try {
        const response = await fetch(url, {
            ...options,
            headers
        });

        if (!response.ok) {
            if (response.status === 401) {
                logout();
                throw new Error('Please login first');
            }
            const error = await response.json();
            throw new Error(error.detail || error.error || 'API Error');
        }

        return await response.json();
    } catch (error) {
        console.error(`API Error: ${endpoint}`, error);
        throw error;
    }
}

/**
 * Get products list with optional filters
 */
function getProducts(params = {}) {
    let query = '';
    if (Object.keys(params).length > 0) {
        query = '?' + new URLSearchParams(params).toString();
    }
    return apiCall(`/products/${query}`, { authenticated: false });
}

/**
 * Get featured products
 */
function getFeaturedProducts() {
    return apiCall('/products/featured/', { authenticated: false });
}

/**
 * Get products by category
 */
function getProductsByCategory(categoryId) {
    return apiCall(`/products/by_category/?category=${categoryId}`, { authenticated: false });
}

/**
 * Get all categories
 */
function getCategories() {
    return apiCall('/categories/', { authenticated: false });
}

/**
 * Register new user
 */
function registerUser(userData) {
    return apiCall('/users/register/', {
        method: 'POST',
        credentials: 'include',
        body: JSON.stringify(userData),
        authenticated: false
    });
}

/**
 * Login user
 */
function loginUser(credentials) {
    return apiCall('/users/login/', {
        method: 'POST',
        credentials: 'include',
        body: JSON.stringify(credentials),
        authenticated: false
    });
}

/**
 * Logout user
 */
function logoutUser() {
    const token = getToken();
    if (token) {
        return apiCall('/users/logout/', {
            method: 'POST'
        });
    }
    return Promise.resolve();
}

/**
 * Get user profile
 */
function getUserProfile() {
    return apiCall('/users/profile/');
}

/**
 * Update user profile
 */
function updateUserProfile(userData) {
    return apiCall('/users/profile/', {
        method: 'PATCH',
        body: JSON.stringify(userData)
    });
}

/**
 * Create new order
 */
function createOrder(orderData) {
    return apiCall('/orders/', {
        method: 'POST',
        body: JSON.stringify(orderData)
    });
}

/**
 * Get user's orders
 */
function getMyOrders() {
    return apiCall('/orders/my_orders/');
}

/**
 * Get order detail
 */
function getOrderDetail(orderId) {
    return apiCall(`/orders/${orderId}/`);
}

/**
 * Update order status
 */
function updateOrderStatus(orderId, status) {
    return apiCall(`/orders/${orderId}/update_status/`, {
        method: 'PATCH',
        body: JSON.stringify({ status })
    });
}
