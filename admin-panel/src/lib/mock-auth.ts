// Mock authentication for development
export const mockAuth = {
  currentUser: {
    uid: 'admin-123',
    email: 'admin@afro.com',
    displayName: 'Admin User'
  },
  
  onAuthStateChanged: (callback: any) => {
    // Simulate immediate authentication
    setTimeout(() => {
      callback({
        uid: 'admin-123',
        email: 'admin@afro.com',
        displayName: 'Admin User'
      });
    }, 100);
    
    // Return unsubscribe function
    return () => {};
  },
  
  signInWithEmailAndPassword: async (email: string, password: string) => {
    if (email === 'admin@afro.com' && password === 'admin123') {
      return {
        user: {
          uid: 'admin-123',
          email: 'admin@afro.com',
          displayName: 'Admin User'
        }
      };
    }
    throw new Error('Invalid credentials');
  },
  
  signOut: async () => {
    return Promise.resolve();
  }
};
