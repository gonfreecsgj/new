import React, { useState } from 'react';
import { useQuery } from 'react-query';
import axios from 'axios';
import { Link } from 'react-router-dom';
import { Search, Plus, Filter, MoreVertical, CheckCircle, XCircle, Clock } from 'lucide-react';
import toast from 'react-hot-toast';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

const fetchManagers = async (page, search, status) => {
  const params = new URLSearchParams();
  params.append('page', page);
  if (search) params.append('search', search);
  if (status) params.append('status', status);
  
  const response = await axios.get(`${API_URL}/admin/managers?${params}`);
  return response.data;
};

const Managers = () => {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');
  const [showTokenModal, setShowTokenModal] = useState(false);
  const [selectedManager, setSelectedManager] = useState(null);
  const [months, setMonths] = useState(1);
  const [generatedToken, setGeneratedToken] = useState('');

  const { data, isLoading, refetch } = useQuery(
    ['managers', page, search, status],
    () => fetchManagers(page, search, status),
    { keepPreviousData: true }
  );

  const handleGenerateToken = async () => {
    try {
      const response = await axios.post(`${API_URL}/admin/generate-token`, {
        managerId: selectedManager._id,
        months
      });
      setGeneratedToken(response.data.data.token);
      toast.success('تم توليد الرمز بنجاح');
    } catch (error) {
      toast.error('فشل توليد الرمز');
    }
  };

  const handleActivate = async (id) => {
    try {
      await axios.post(`${API_URL}/admin/managers/${id}/activate`, { months: 1 });
      toast.success('تم تفعيل الاشتراك');
      refetch();
    } catch (error) {
      toast.error('فشل التفعيل');
    }
  };

  const handleSuspend = async (id) => {
    try {
      await axios.post(`${API_URL}/admin/managers/${id}/suspend`);
      toast.success('تم إيقاف الحساب');
      refetch();
    } catch (error) {
      toast.error('فشل الإيقاف');
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'active':
        return <CheckCircle className="w-5 h-5 text-green-500" />;
      case 'trial':
        return <Clock className="w-5 h-5 text-yellow-500" />;
      case 'expired':
      case 'suspended':
        return <XCircle className="w-5 h-5 text-red-500" />;
      default:
        return null;
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'trial':
        return 'تجربة';
      case 'expired':
        return 'منتهي';
      case 'suspended':
        return 'موقوف';
      default:
        return status;
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <h1 className="text-3xl font-bold text-white">المدراء</h1>
        <div className="flex gap-3">
          <div className="relative">
            <Search className="absolute right-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-500" />
            <input
              type="text"
              placeholder="بحث..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="bg-gray-700 border border-gray-600 rounded-lg py-2 pr-10 pl-4 text-white w-64"
            />
          </div>
          <select
            value={status}
            onChange={(e) => setStatus(e.target.value)}
            className="bg-gray-700 border border-gray-600 rounded-lg py-2 px-4 text-white"
          >
            <option value="">الكل</option>
            <option value="active">نشط</option>
            <option value="trial">تجربة</option>
            <option value="expired">منتهي</option>
            <option value="suspended">موقوف</option>
          </select>
        </div>
      </div>

      {/* Table */}
      <div className="bg-gray-800 rounded-xl border border-gray-700 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-700/50">
              <tr>
                <th className="px-6 py-4 text-right text-gray-400">المدير</th>
                <th className="px-6 py-4 text-right text-gray-400">الحالة</th>
                <th className="px-6 py-4 text-right text-gray-400">الاشتراك</th>
                <th className="px-6 py-4 text-right text-gray-400">الكروت</th>
                <th className="px-6 py-4 text-right text-gray-400">تاريخ التسجيل</th>
                <th className="px-6 py-4 text-right text-gray-400">إجراءات</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-700">
              {isLoading ? (
                <tr>
                  <td colSpan="6" className="px-6 py-8 text-center text-gray-400">
                    جاري التحميل...
                  </td>
                </tr>
              ) : data?.data?.length === 0 ? (
                <tr>
                  <td colSpan="6" className="px-6 py-8 text-center text-gray-400">
                    لا يوجد مدراء
                  </td>
                </tr>
              ) : (
                data?.data?.map((manager) => (
                  <tr key={manager._id} className="hover:bg-gray-700/30">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-gradient-to-r from-cyan-500 to-purple-600 rounded-full flex items-center justify-center">
                          <span className="text-white font-bold">
                            {manager.name?.charAt(0).toUpperCase()}
                          </span>
                        </div>
                        <div>
                          <p className="text-white font-medium">{manager.name}</p>
                          <p className="text-gray-400 text-sm">{manager.email}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {getStatusIcon(manager.status)}
                        <span className={`${
                          manager.status === 'active' ? 'text-green-400' :
                          manager.status === 'trial' ? 'text-yellow-400' :
                          'text-red-400'
                        }`}>
                          {getStatusText(manager.status)}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="text-white">{manager.daysLeft} يوم</span>
                    </td>
                    <td className="px-6 py-4 text-white">
                      {manager.stats?.totalVouchers || 0}
                    </td>
                    <td className="px-6 py-4 text-gray-400">
                      {new Date(manager.createdAt).toLocaleDateString('ar-SA')}
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => {
                            setSelectedManager(manager);
                            setShowTokenModal(true);
                          }}
                          className="p-2 bg-cyan-500/20 text-cyan-400 rounded-lg hover:bg-cyan-500/30"
                          title="توليد رمز"
                        >
                          <Plus className="w-4 h-4" />
                        </button>
                        {manager.status !== 'active' && (
                          <button
                            onClick={() => handleActivate(manager._id)}
                            className="p-2 bg-green-500/20 text-green-400 rounded-lg hover:bg-green-500/30"
                            title="تفعيل"
                          >
                            <CheckCircle className="w-4 h-4" />
                          </button>
                        )}
                        {manager.status !== 'suspended' && (
                          <button
                            onClick={() => handleSuspend(manager._id)}
                            className="p-2 bg-red-500/20 text-red-400 rounded-lg hover:bg-red-500/30"
                            title="إيقاف"
                          >
                            <XCircle className="w-4 h-4" />
                          </button>
                        )}
                        <Link
                          to={`/managers/${manager._id}`}
                          className="p-2 bg-gray-700 text-gray-400 rounded-lg hover:bg-gray-600"
                        >
                          <MoreVertical className="w-4 h-4" />
                        </Link>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {data?.pagination && (
          <div className="px-6 py-4 border-t border-gray-700 flex items-center justify-between">
            <p className="text-gray-400">
              عرض {((page - 1) * 20) + 1} - {Math.min(page * 20, data.pagination.total)} من {data.pagination.total}
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="px-4 py-2 bg-gray-700 text-white rounded-lg disabled:opacity-50"
              >
                السابق
              </button>
              <button
                onClick={() => setPage(p => Math.min(data.pagination.pages, p + 1))}
                disabled={page === data.pagination.pages}
                className="px-4 py-2 bg-gray-700 text-white rounded-lg disabled:opacity-50"
              >
                التالي
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Token Modal */}
      {showTokenModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-gray-800 rounded-xl p-6 w-full max-w-md border border-gray-700">
            <h2 className="text-xl font-bold text-white mb-4">توليد رمز تفعيل</h2>
            <p className="text-gray-400 mb-4">للمدير: {selectedManager?.name}</p>
            
            <div className="mb-4">
              <label className="block text-gray-400 mb-2">عدد الأشهر</label>
              <input
                type="number"
                min="1"
                max="12"
                value={months}
                onChange={(e) => setMonths(parseInt(e.target.value))}
                className="w-full bg-gray-700 border border-gray-600 rounded-lg py-2 px-4 text-white"
              />
            </div>

            {generatedToken && (
              <div className="mb-4 p-4 bg-cyan-500/10 border border-cyan-500/30 rounded-lg">
                <p className="text-cyan-400 font-mono text-lg">{generatedToken}</p>
                <button
                  onClick={() => navigator.clipboard.writeText(generatedToken)}
                  className="mt-2 text-sm text-cyan-400 hover:underline"
                >
                  نسخ الرمز
                </button>
              </div>
            )}

            <div className="flex gap-3">
              <button
                onClick={handleGenerateToken}
                className="flex-1 bg-gradient-to-r from-cyan-500 to-purple-600 text-white font-bold py-2 rounded-lg"
              >
                توليد
              </button>
              <button
                onClick={() => {
                  setShowTokenModal(false);
                  setGeneratedToken('');
                }}
                className="flex-1 bg-gray-700 text-white py-2 rounded-lg"
              >
                إغلاق
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Managers;
