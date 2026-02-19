import React, { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';
import toast from 'react-hot-toast';

const AuthContext = createContext();

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('adminToken');
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      // Verify token
      checkAuth();
    } else {
      setLoading(false);
    }
  }, []);

  const checkAuth = async () => {
    try {
      const response = await axios.get(`${API_URL}/admin/dashboard`);
      if (response.data.success) {
        setUser({ email: 'alshamytlal702@gmail.com' });
      }
    } catch (error) {
      logout();
    } finally {
      setLoading(false);
    }
  };

  const login = async (email, password) => {
    try {
      // For now, simple validation
      if (email === 'alshamytlal702@gmail.com' && password === 'mmm771834027mmm') {
        const token = 'admin-jwt-token'; // In production, get from server
        localStorage.setItem('adminToken', token);
        axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        setUser({ email });
        toast.success('تم تسجيل الدخول بنجاح');
        return true;
      } else {
        toast.error('بيانات الدخول غير صحيحة');
        return false;
      }
    } catch (error) {
      toast.error('حدث خطأ أثناء تسجيل الدخول');
      return false;
    }
  };

  const logout = () => {
    localStorage.removeItem('adminToken');
    delete axios.defaults.headers.common['Authorization'];
    setUser(null);
    toast.success('تم تسجيل الخروج');
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
