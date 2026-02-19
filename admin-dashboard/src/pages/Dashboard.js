import React from 'react';
import { useQuery } from 'react-query';
import axios from 'axios';
import { 
  Users, 
  CreditCard, 
  TrendingUp, 
  AlertTriangle,
  DollarSign,
  Activity
} from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

const fetchDashboard = async () => {
  const response = await axios.get(`${API_URL}/admin/dashboard`);
  return response.data.data;
};

const Dashboard = () => {
  const { data, isLoading } = useQuery('dashboard', fetchDashboard, {
    refetchInterval: 30000, // Refetch every 30 seconds
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-cyan-500"></div>
      </div>
    );
  }

  const stats = data?.stats || {};
  const expiringSoon = data?.expiringSoon || [];

  const statCards = [
    { 
      title: 'إجمالي المدراء', 
      value: stats.totalManagers || 0, 
      icon: Users, 
      color: 'bg-blue-500',
      trend: '+12%' 
    },
    { 
      title: 'المدراء النشطون', 
      value: stats.activeManagers || 0, 
      icon: Activity, 
      color: 'bg-green-500',
      trend: '+5%' 
    },
    { 
      title: 'إجمالي الإيرادات', 
      value: `$${(stats.totalRevenue || 0).toFixed(2)}`, 
      icon: DollarSign, 
      color: 'bg-purple-500',
      trend: '+23%' 
    },
    { 
      title: 'إجمالي الكروت', 
      value: stats.totalVouchers || 0, 
      icon: CreditCard, 
      color: 'bg-orange-500',
      trend: '+18%' 
    },
  ];

  // Sample chart data
  const chartData = [
    { name: 'يناير', revenue: 400 },
    { name: 'فبراير', revenue: 300 },
    { name: 'مارس', revenue: 600 },
    { name: 'أبريل', revenue: 800 },
    { name: 'مايو', revenue: 500 },
    { name: 'يونيو', revenue: 900 },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-white">لوحة التحكم</h1>
        <div className="flex items-center space-x-2 space-x-reverse">
          <span className="text-gray-400">آخر تحديث:</span>
          <span className="text-cyan-400">{new Date().toLocaleTimeString('ar-SA')}</span>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statCards.map((card, index) => (
          <div key={index} className="bg-gray-800 rounded-xl p-6 border border-gray-700">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-gray-400 text-sm">{card.title}</p>
                <p className="text-3xl font-bold text-white mt-2">{card.value}</p>
                <span className="text-green-400 text-sm">{card.trend}</span>
              </div>
              <div className={`${card.color} p-3 rounded-lg`}>
                <card.icon className="w-6 h-6 text-white" />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Charts & Alerts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Revenue Chart */}
        <div className="lg:col-span-2 bg-gray-800 rounded-xl p-6 border border-gray-700">
          <h2 className="text-xl font-bold text-white mb-4">الإيرادات الشهرية</h2>
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="name" stroke="#9CA3AF" />
                <YAxis stroke="#9CA3AF" />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#1F2937', border: 'none' }}
                  labelStyle={{ color: '#fff' }}
                />
                <Line 
                  type="monotone" 
                  dataKey="revenue" 
                  stroke="#06B6D4" 
                  strokeWidth={3}
                  dot={{ fill: '#06B6D4' }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Alerts */}
        <div className="bg-gray-800 rounded-xl p-6 border border-gray-700">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-bold text-white">تنبيهات</h2>
            <AlertTriangle className="w-5 h-5 text-yellow-500" />
          </div>
          
          <div className="space-y-4">
            {expiringSoon.length > 0 ? (
              expiringSoon.map((manager) => (
                <div 
                  key={manager.id} 
                  className="bg-yellow-500/10 border border-yellow-500/30 rounded-lg p-4"
                >
                  <div className="flex items-start space-x-3 space-x-reverse">
                    <AlertTriangle className="w-5 h-5 text-yellow-500 flex-shrink-0 mt-0.5" />
                    <div>
                      <p className="text-white font-medium">{manager.name}</p>
                      <p className="text-yellow-400 text-sm">
                        ينتهي الاشتراك خلال {manager.daysLeft} يوم
                      </p>
                    </div>
                  </div>
                </div>
              ))
            ) : (
              <p className="text-gray-400 text-center py-8">لا توجد تنبيهات</p>
            )}
          </div>
        </div>
      </div>

      {/* Recent Managers */}
      <div className="bg-gray-800 rounded-xl border border-gray-700 overflow-hidden">
        <div className="p-6 border-b border-gray-700">
          <h2 className="text-xl font-bold text-white">آخر المسجلين</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-700/50">
              <tr>
                <th className="px-6 py-3 text-right text-gray-400">الاسم</th>
                <th className="px-6 py-3 text-right text-gray-400">البريد</th>
                <th className="px-6 py-3 text-right text-gray-400">الحالة</th>
                <th className="px-6 py-3 text-right text-gray-400">تاريخ التسجيل</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-700">
              {data?.recentManagers?.map((manager) => (
                <tr key={manager._id} className="hover:bg-gray-700/30">
                  <td className="px-6 py-4 text-white">{manager.name}</td>
                  <td className="px-6 py-4 text-gray-400">{manager.email}</td>
                  <td className="px-6 py-4">
                    <span className={`px-3 py-1 rounded-full text-sm ${
                      manager.status === 'active' 
                        ? 'bg-green-500/20 text-green-400' 
                        : manager.status === 'trial'
                        ? 'bg-yellow-500/20 text-yellow-400'
                        : 'bg-red-500/20 text-red-400'
                    }`}>
                      {manager.status === 'active' ? 'نشط' : 
                       manager.status === 'trial' ? 'تجربة' : 'منتهي'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-gray-400">
                    {new Date(manager.createdAt).toLocaleDateString('ar-SA')}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
