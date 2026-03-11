'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/Sidebar';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';
import {
  Search,
  Filter,
  Download,
  UserPlus,
  MoreVertical,
  Eye,
  Edit,
  Ban,
  CheckCircle,
  Trash2,
  Mail,
  Phone,
  Calendar,
  Briefcase,
  Award,
  Camera,
  Users,
  TrendingUp,
  Activity,
  Clock,
  Star,
  AlertCircle,
  Settings,
  BarChart3,
  X,
  Save,
  User,
  Lock,
  MapPin
} from 'lucide-react';

interface User {
  id: string;
  email: string;
  name: string;
  phone?: string | null;
  roles: Array<{ role: string }>;
  specialization?: string | null;
  isActive: boolean;
  createdAt: string;
  avatar?: string | null;
  portfolioImages?: string[];
  experienceYears?: number | null;
}

interface NewUser {
  name: string;
  email: string;
  phone: string;
  role: string;
  specialization?: string;
  experienceYears?: number;
  password: string;
  confirmPassword: string;
}

export default function UsersPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [specializationFilter, setSpecializationFilter] = useState('all');
  const [selectedUsers, setSelectedUsers] = useState<string[]>([]);
  const [showDropdown, setShowDropdown] = useState<string | null>(null);
  const [quickFilters, setQuickFilters] = useState<string[]>([]);
  const [showAddUserModal, setShowAddUserModal] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // New modal states
  const [showViewModal, setShowViewModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [editFormData, setEditFormData] = useState({
    name: '',
    email: '',
    phone: '',
    isActive: true
  });

  const [newUser, setNewUser] = useState<NewUser>({
    name: '',
    email: '',
    phone: '',
    role: 'customer',
    specialization: '',
    experienceYears: undefined,
    password: '',
    confirmPassword: ''
  });

  useEffect(() => {
    if (authenticated) {
      loadUsers();
    }
  }, [authenticated]);

  const loadUsers = async () => {
    try {
      console.log('Loading users from API...');
      const response = await api.getAllUsers();
      console.log('API response:', response);

      // Always use API response data
      if (response.data) {
        console.log('Setting users from API:', response.data);
        setUsers(response.data);
      } else {
        console.log('No data in response, setting empty array');
        setUsers([]);
      }
    } catch (error) {
      console.error('Error loading users:', error);
      toast.error('Failed to load users');
      setUsers([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSuspend = async (userId: string) => {
    try {
      await api.suspendUser(userId);
      toast.success('User suspended');
      loadUsers();
    } catch (error: any) {
      console.error('Suspend user error:', error);
      if (error.response?.status === 404) {
        toast.error('User not found');
      } else if (error.response?.status === 403) {
        toast.error('You do not have permission to suspend this user');
      } else if (error.response?.status === 401) {
        toast.error('Authentication failed. Please log in again.');
      } else if (error.response?.status === 500) {
        toast.error('Server error. Please try again later.');
      } else {
        toast.error('Failed to suspend user');
      }
    }
  };

  const handleActivate = async (userId: string) => {
    try {
      await api.activateUser(userId);
      toast.success('User activated successfully');
      loadUsers();
    } catch (error: any) {
      console.error('Activate user error:', error);
      if (error.response?.status === 404) {
        toast.error('User not found');
      } else if (error.response?.status === 403) {
        toast.error('You do not have permission to activate this user');
      } else if (error.response?.status === 401) {
        toast.error('Authentication failed. Please log in again.');
      } else if (error.response?.status === 500) {
        toast.error('Server error. Please try again later.');
      } else {
        toast.error('Failed to activate user');
      }
    }
  };

  const handleDelete = async (userId: string) => {
    if (!confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
      return;
    }

    try {
      await api.deleteUser(userId);
      toast.success('User deleted successfully');
      loadUsers();
    } catch (error: any) {
      console.error('Delete user error:', error);
      if (error.response?.status === 404) {
        toast.error('User not found');
      } else if (error.response?.status === 403) {
        toast.error('You do not have permission to delete this user');
      } else if (error.response?.status === 401) {
        toast.error('Authentication failed. Please log in again.');
      } else if (error.response?.status === 500) {
        toast.error('Server error. Please try again later.');
      } else {
        toast.error('Failed to delete user');
      }
    }
  };

  const handleView = (userId: string) => {
    const user = users.find(u => u.id === userId);
    if (user) {
      setSelectedUser(user);
      setShowViewModal(true);
      setShowDropdown(null);
    }
  };

  const handleEdit = (userId: string) => {
    const user = users.find(u => u.id === userId);
    if (user) {
      setSelectedUser(user);
      setEditFormData({
        name: user.name,
        email: user.email,
        phone: user.phone || '',
        isActive: user.isActive
      });
      setShowEditModal(true);
      setShowDropdown(null);
    }
  };

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedUser) return;

    try {
      setIsSubmitting(true);
      await api.updateUser(selectedUser.id, editFormData);
      toast.success('User updated successfully');
      setShowEditModal(false);
      setSelectedUser(null);
      loadUsers();
    } catch (error: any) {
      console.error('Edit user error:', error);
      if (error.response?.status === 404) {
        toast.error('User not found');
      } else if (error.response?.status === 403) {
        toast.error('You do not have permission to edit this user');
      } else if (error.response?.status === 401) {
        toast.error('Authentication failed. Please log in again.');
      } else if (error.response?.status === 500) {
        toast.error('Server error. Please try again later.');
      } else {
        toast.error('Failed to update user');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleEditChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    setEditFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value
    }));
  };

  const handleBulkAction = async (action: string) => {
    if (selectedUsers.length === 0) {
      toast.error('Please select users first');
      return;
    }

    try {
      if (action === 'suspend') {
        await Promise.all(selectedUsers.map(id => api.suspendUser(id)));
        toast.success(`${selectedUsers.length} users suspended`);
      } else if (action === 'activate') {
        await Promise.all(selectedUsers.map(id => api.activateUser(id)));
        toast.success(`${selectedUsers.length} users activated`);
      } else if (action === 'delete') {
        if (confirm(`Are you sure you want to delete ${selectedUsers.length} users?`)) {
          await Promise.all(selectedUsers.map(id => api.deleteUser(id)));
          toast.success(`${selectedUsers.length} users deleted`);
        }
      }
      setSelectedUsers([]);
      loadUsers();
    } catch (error) {
      toast.error(`Failed to ${action} users`);
    }
  };

  const filteredUsers = users.filter(user => {
    const matchesSearch = searchTerm === '' ||
      user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesRole = roleFilter === 'all' ||
      user.roles.some(r => r.role === roleFilter);

    const matchesStatus = statusFilter === 'all' ||
      (statusFilter === 'active' && user.isActive) ||
      (statusFilter === 'inactive' && !user.isActive);

    const matchesSpecialization = specializationFilter === 'all' ||
      user.specialization === specializationFilter;

    const matchesQuickFilters = quickFilters.length === 0 ||
      quickFilters.some(filter => {
        if (filter === 'new') {
          const createdAt = new Date(user.createdAt);
          const weekAgo = new Date();
          weekAgo.setDate(weekAgo.getDate() - 7);
          return createdAt > weekAgo;
        }
        if (filter === 'inactive') return !user.isActive;
        if (filter === 'staff') return user.roles.some(r => r.role === 'staff');
        if (filter === 'customers') return user.roles.some(r => r.role === 'customer');
        return false;
      });

    return matchesSearch && matchesRole && matchesStatus && matchesSpecialization && matchesQuickFilters;
  });

  const stats = {
    total: users.length,
    active: users.filter(u => u.isActive).length,
    staff: users.filter(u => u.roles.some(r => r.role === 'staff')).length,
    customers: users.filter(u => u.roles.some(r => r.role === 'customer')).length,
    newThisWeek: users.filter(u => {
      const createdAt = new Date(u.createdAt);
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      return createdAt > weekAgo;
    }).length
  };

  const handleAddUser = () => {
    console.log('Add User button clicked!');
    console.log('Current modal state:', showAddUserModal);
    setShowAddUserModal(prev => {
      console.log('Setting modal to true, previous state:', prev);
      return true;
    });
    console.log('Modal state update queued');
  };

  const handleCreateUser = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validate required fields
    if (!newUser.name.trim()) {
      toast.error('Name is required');
      return;
    }

    if (!newUser.email.trim()) {
      toast.error('Email is required');
      return;
    }

    if (!newUser.role) {
      toast.error('Role is required');
      return;
    }

    if (!newUser.password) {
      toast.error('Password is required');
      return;
    }

    if (newUser.password !== newUser.confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }

    if (newUser.password.length < 8) {
      toast.error('Password must be at least 8 characters');
      return;
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(newUser.email)) {
      toast.error('Please enter a valid email address');
      return;
    }

    setIsSubmitting(true);
    try {
      const userData: any = {
        name: newUser.name.trim(),
        email: newUser.email.trim().toLowerCase(),
        role: newUser.role,
        password: newUser.password
      };

      // Add optional fields only if they have values
      if (newUser.phone && newUser.phone.trim()) {
        userData.phone = newUser.phone.trim();
      }

      if (newUser.role === 'staff') {
        if (newUser.specialization) {
          userData.specialization = newUser.specialization;
        }
        if (newUser.experienceYears !== undefined && newUser.experienceYears !== null) {
          userData.experienceYears = parseInt(newUser.experienceYears.toString());
        }
      }

      console.log('Sending user data:', userData);
      const response = await api.createUser(userData);
      console.log('User creation response:', response);

      toast.success('User created successfully');
      setShowAddUserModal(false);
      setNewUser({
        name: '',
        email: '',
        phone: '',
        role: 'customer',
        specialization: '',
        experienceYears: undefined,
        password: '',
        confirmPassword: ''
      });
      loadUsers();
    } catch (error: any) {
      console.error('User creation error:', error);

      // Handle different types of errors
      if (error.response?.status === 400) {
        toast.error(error.response.data?.message || 'Invalid user data provided');
      } else if (error.response?.status === 409) {
        toast.error('User with this email already exists');
      } else if (error.response?.status === 500) {
        toast.error('Server error. Please try again later.');
      } else if (error.code === 'NETWORK_ERROR') {
        toast.error('Network error. Please check your connection.');
      } else {
        toast.error(error.response?.data?.message || error.message || 'Failed to create user');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleExport = () => {
    toast('Exporting users data...');
    // Add export functionality here
  };

  if (authLoading || loading) {
    return (
      <div className="flex">
        <Sidebar />
        <div className="main-content flex items-center justify-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex">
      <Sidebar />
      <div className="main-content without-sidebar">
        {/* Header */}
        <div className="header">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Beauty Professionals Management</h1>
            <p className="text-gray-600">Manage all users, staff, and beauty professionals</p>
          </div>
          <div className="flex gap-3">
            <button onClick={handleExport} className="btn btn-secondary">
              <Download className="w-4 h-4" />
              Export
            </button>
            <button onClick={handleAddUser} className="btn btn-primary">
              <UserPlus className="w-4 h-4" />
              Add User
            </button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="stats-grid">
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Total Users</p>
                <p className="stat-value">{stats.total}</p>
                <p className="stat-change positive">
                  <TrendingUp className="w-3 h-3" />
                  +12% from last month
                </p>
              </div>
              <Users className="w-8 h-8 text-primary" />
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Active Users</p>
                <p className="stat-value">{stats.active}</p>
                <p className="stat-change positive">
                  <TrendingUp className="w-3 h-3" />
                  +8% from last month
                </p>
              </div>
              <Activity className="w-8 h-8 text-success" />
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">Staff Members</p>
                <p className="stat-value">{stats.staff}</p>
                <p className="stat-change positive">
                  <TrendingUp className="w-3 h-3" />
                  +2 new this month
                </p>
              </div>
              <Briefcase className="w-8 h-8 text-warning" />
            </div>
          </div>
          <div className="stat-card">
            <div className="flex items-center justify-between">
              <div>
                <p className="stat-label">New This Week</p>
                <p className="stat-value">{stats.newThisWeek}</p>
                <p className="stat-change positive">
                  <Clock className="w-3 h-3" />
                  +{stats.newThisWeek} signups
                </p>
              </div>
              <Star className="w-8 h-8 text-info" />
            </div>
          </div>
        </div>

        {/* Filters */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold">Filters</h2>
            <button
              onClick={() => {
                setSearchTerm('');
                setRoleFilter('all');
                setStatusFilter('all');
                setSpecializationFilter('all');
                setQuickFilters([]);
              }}
              className="text-sm text-gray-500 hover:text-gray-700"
            >
              Clear all
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Search users..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input pl-10"
              />
            </div>

            <select
              value={roleFilter}
              onChange={(e) => setRoleFilter(e.target.value)}
              className="input"
            >
              <option value="all">All Roles</option>
              <option value="admin">Admin</option>
              <option value="staff">Staff</option>
              <option value="customer">Customer</option>
            </select>

            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="input"
            >
              <option value="all">All Status</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>

            <select
              value={specializationFilter}
              onChange={(e) => setSpecializationFilter(e.target.value)}
              className="input"
            >
              <option value="all">All Specializations</option>
              <option value="barber">Barber</option>
              <option value="hair_stylist">Hair Stylist</option>
              <option value="makeup_artist">Makeup Artist</option>
              <option value="nail_technician">Nail Technician</option>
            </select>
          </div>

          {/* Quick Filters */}
          <div className="mt-4">
            <p className="text-sm font-medium text-gray-700 mb-2">Quick Filters:</p>
            <div className="flex flex-wrap gap-2">
              {['new', 'inactive', 'staff', 'customers'].map(filter => (
                <button
                  key={filter}
                  onClick={() => {
                    setQuickFilters(prev =>
                      prev.includes(filter)
                        ? prev.filter(f => f !== filter)
                        : [...prev, filter]
                    );
                  }}
                  className={`filter-chip ${quickFilters.includes(filter) ? 'active' : ''}`}
                >
                  {filter.charAt(0).toUpperCase() + filter.slice(1)}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Inline Stats and Actions */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Quick Actions Section */}
          <div className="card">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Star className="w-5 h-5 text-primary" />
              Quick Actions
            </h3>
            <div className="space-y-3">
              <button onClick={handleAddUser} className="quick-action-btn primary w-full">
                <UserPlus className="w-4 h-4" />
                Add New User
              </button>
              <button onClick={handleExport} className="quick-action-btn w-full">
                <Download className="w-4 h-4" />
                Export Users
              </button>
              <button className="quick-action-btn w-full">
                <Mail className="w-4 h-4" />
                Send Newsletter
              </button>
            </div>
          </div>

          {/* Statistics Section */}
          <div className="card">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <BarChart3 className="w-5 h-5 text-primary" />
              Statistics
            </h3>
            <div className="space-y-3">
              <div className="quick-stat">
                <span className="quick-stat-label">Total Users</span>
                <span className="quick-stat-value">{stats.total}</span>
              </div>
              <div className="quick-stat">
                <span className="quick-stat-label">Active Users</span>
                <span className="quick-stat-value">{stats.active}</span>
              </div>
              <div className="quick-stat">
                <span className="quick-stat-label">Staff Members</span>
                <span className="quick-stat-value">{stats.staff}</span>
              </div>
              <div className="quick-stat">
                <span className="quick-stat-label">Customers</span>
                <span className="quick-stat-value">{stats.customers}</span>
              </div>
              <div className="quick-stat">
                <span className="quick-stat-label">New This Week</span>
                <span className="quick-stat-value">{stats.newThisWeek}</span>
              </div>
            </div>
          </div>

          {/* Recent Activity Section */}
          <div className="card">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Activity className="w-5 h-5 text-primary" />
              Recent Activity
            </h3>
            <div className="space-y-3">
              <div className="activity-item">
                <div className="activity-icon bg-green-100 text-green-600">
                  <UserPlus className="w-4 h-4" />
                </div>
                <div className="activity-content">
                  <p className="activity-title">New user registered</p>
                  <p className="activity-time">2 minutes ago</p>
                </div>
              </div>
              <div className="activity-item">
                <div className="activity-icon bg-blue-100 text-blue-600">
                  <Edit className="w-4 h-4" />
                </div>
                <div className="activity-content">
                  <p className="activity-title">User profile updated</p>
                  <p className="activity-time">15 minutes ago</p>
                </div>
              </div>
              <div className="activity-item">
                <div className="activity-icon bg-yellow-100 text-yellow-600">
                  <Ban className="w-4 h-4" />
                </div>
                <div className="activity-content">
                  <p className="activity-title">User suspended</p>
                  <p className="activity-time">1 hour ago</p>
                </div>
              </div>
              <div className="activity-item">
                <div className="activity-icon bg-red-100 text-red-600">
                  <Trash2 className="w-4 h-4" />
                </div>
                <div className="activity-content">
                  <p className="activity-title">User deleted</p>
                  <p className="activity-time">2 hours ago</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Users Table */}
        <div className="table-container">
          <div className="flex items-center justify-between p-4 border-b">
            <div className="flex items-center gap-4">
              <h2 className="text-lg font-semibold">Users ({filteredUsers.length})</h2>
              {selectedUsers.length > 0 && (
                <span className="text-sm text-gray-500">
                  {selectedUsers.length} selected
                </span>
              )}
            </div>

            {selectedUsers.length > 0 && (
              <div className="flex items-center gap-2">
                <button
                  onClick={() => handleBulkAction('activate')}
                  className="btn btn-secondary text-sm"
                >
                  <CheckCircle className="w-4 h-4" />
                  Activate
                </button>
                <button
                  onClick={() => handleBulkAction('suspend')}
                  className="btn btn-secondary text-sm"
                >
                  <Ban className="w-4 h-4" />
                  Suspend
                </button>
                <button
                  onClick={() => handleBulkAction('delete')}
                  className="btn btn-danger text-sm"
                >
                  <Trash2 className="w-4 h-4" />
                  Delete
                </button>
              </div>
            )}
          </div>

          <table className="table">
            <thead>
              <tr>
                <th>
                  <input
                    type="checkbox"
                    checked={selectedUsers.length === filteredUsers.length}
                    onChange={(e) => {
                      if (e.target.checked) {
                        setSelectedUsers(filteredUsers.map(u => u.id));
                      } else {
                        setSelectedUsers([]);
                      }
                    }}
                  />
                </th>
                <th>User</th>
                <th>Role</th>
                <th>Specialization</th>
                <th>Status</th>
                <th>Joined</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.map((user) => (
                <tr key={user.id}>
                  <td>
                    <input
                      type="checkbox"
                      checked={selectedUsers.includes(user.id)}
                      onChange={(e) => {
                        if (e.target.checked) {
                          setSelectedUsers(prev => [...prev, user.id]);
                        } else {
                          setSelectedUsers(prev => prev.filter(id => id !== user.id));
                        }
                      }}
                    />
                  </td>
                  <td>
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                        <User className="w-5 h-5 text-gray-500" />
                      </div>
                      <div>
                        <p className="font-medium">{user.name}</p>
                        <p className="text-sm text-gray-500">{user.email}</p>
                        {user.phone && (
                          <p className="text-sm text-gray-500">{user.phone}</p>
                        )}
                      </div>
                    </div>
                  </td>
                  <td>
                    <span className={`badge ${user.roles.some(r => r.role === 'admin') ? 'badge-error' :
                      user.roles.some(r => r.role === 'staff') ? 'badge-warning' : 'badge-success'
                      }`}>
                      {user.roles.map(r => r.role).join(', ')}
                    </span>
                  </td>
                  <td>
                    {user.specialization ? (
                      <span className="badge badge-info">{user.specialization.replace('_', ' ')}</span>
                    ) : (
                      <span className="text-gray-400">-</span>
                    )}
                  </td>
                  <td>
                    <span className={`badge ${user.isActive ? 'badge-success' : 'badge-error'}`}>
                      {user.isActive ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td>
                    <p className="text-sm">{new Date(user.createdAt).toLocaleDateString()}</p>
                  </td>
                  <td>
                    <div className="relative">
                      <button
                        onClick={() => setShowDropdown(showDropdown === user.id ? null : user.id)}
                        className="btn btn-secondary"
                      >
                        <MoreVertical className="w-4 h-4" />
                      </button>

                      {showDropdown === user.id && (
                        <div className="dropdown">
                          <button onClick={() => handleView(user.id)} className="dropdown-item">
                            <Eye className="w-4 h-4" />
                            View Details
                          </button>
                          <button onClick={() => handleEdit(user.id)} className="dropdown-item">
                            <Edit className="w-4 h-4" />
                            Edit User
                          </button>
                          {user.isActive ? (
                            <button
                              onClick={() => handleSuspend(user.id)}
                              className="dropdown-item"
                            >
                              <Ban className="w-4 h-4" />
                              Suspend
                            </button>
                          ) : (
                            <button
                              onClick={() => handleActivate(user.id)}
                              className="dropdown-item"
                            >
                              <CheckCircle className="w-4 h-4" />
                              Activate
                            </button>
                          )}
                          <div className="dropdown-divider"></div>
                          <button
                            onClick={() => handleDelete(user.id)}
                            className="dropdown-item text-red-600"
                          >
                            <Trash2 className="w-4 h-4" />
                            Delete
                          </button>
                        </div>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add User Modal */}
      {showAddUserModal && (
        <>
          <div className="modal-backdrop" onClick={() => setShowAddUserModal(false)} />
          <div className="modal-content">
            <div className="modal-header">
              <h2>
                <UserPlus className="w-6 h-6 text-primary" />
                Add New User
              </h2>
              <button
                onClick={() => setShowAddUserModal(false)}
                className="close-btn"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateUser}>
              <div className="modal-body">
                {/* Basic Information Section */}
                <div className="form-section">
                  <h3 className="form-section-title">
                    <User className="w-4 h-4" />
                    Basic Information
                  </h3>
                  <div className="form-grid">
                    <div className="form-group">
                      <label className="form-label required">
                        Full Name
                      </label>
                      <input
                        type="text"
                        required
                        value={newUser.name}
                        onChange={(e) => setNewUser(prev => ({ ...prev, name: e.target.value }))}
                        className="form-input"
                        placeholder="Enter full name"
                      />
                    </div>

                    <div className="form-group">
                      <label className="form-label required">
                        Email Address
                      </label>
                      <input
                        type="email"
                        required
                        value={newUser.email}
                        onChange={(e) => setNewUser(prev => ({ ...prev, email: e.target.value }))}
                        className="form-input"
                        placeholder="user@example.com"
                      />
                    </div>

                    <div className="form-group">
                      <label className="form-label">
                        Phone Number
                      </label>
                      <input
                        type="tel"
                        value={newUser.phone}
                        onChange={(e) => setNewUser(prev => ({ ...prev, phone: e.target.value }))}
                        className="form-input"
                        placeholder="+1 (555) 123-4567"
                      />
                      <p className="form-help">Optional - for contact purposes</p>
                    </div>

                    <div className="form-group">
                      <label className="form-label required">
                        User Role
                      </label>
                      <select
                        required
                        value={newUser.role}
                        onChange={(e) => setNewUser(prev => ({ ...prev, role: e.target.value }))}
                        className="form-select"
                      >
                        <option value="">Select Role</option>
                        <option value="customer">Customer</option>
                        <option value="staff">Staff Member</option>
                        <option value="admin">Administrator</option>
                      </select>
                    </div>
                  </div>
                </div>

                {/* Staff Details Section (conditional) */}
                {newUser.role === 'staff' && (
                  <div className="form-section">
                    <h3 className="form-section-title">
                      <Briefcase className="w-4 h-4" />
                      Professional Details
                    </h3>
                    <div className="form-grid">
                      <div className="form-group">
                        <label className="form-label">
                          Specialization
                        </label>
                        <select
                          value={newUser.specialization}
                          onChange={(e) => setNewUser(prev => ({ ...prev, specialization: e.target.value }))}
                          className="form-select"
                        >
                          <option value="">Select Specialization</option>
                          <option value="barber">Barber</option>
                          <option value="hair_stylist">Hair Stylist</option>
                          <option value="makeup_artist">Makeup Artist</option>
                          <option value="nail_technician">Nail Technician</option>
                          <option value="esthetician">Esthetician</option>
                          <option value="massage_therapist">Massage Therapist</option>
                        </select>
                      </div>

                      <div className="form-group">
                        <label className="form-label">
                          Years of Experience
                        </label>
                        <input
                          type="number"
                          min="0"
                          max="50"
                          value={newUser.experienceYears || ''}
                          onChange={(e) => setNewUser(prev => ({
                            ...prev,
                            experienceYears: e.target.value ? parseInt(e.target.value) : undefined
                          }))}
                          className="form-input"
                          placeholder="e.g., 5"
                        />
                        <p className="form-help">Optional - years in the industry</p>
                      </div>
                    </div>
                  </div>
                )}

                {/* Security Section */}
                <div className="form-section">
                  <h3 className="form-section-title">
                    <Lock className="w-4 h-4" />
                    Security Settings
                  </h3>
                  <div className="form-grid">
                    <div className="form-group">
                      <label className="form-label required">
                        Password
                      </label>
                      <input
                        type="password"
                        required
                        value={newUser.password}
                        onChange={(e) => setNewUser(prev => ({ ...prev, password: e.target.value }))}
                        className="form-input"
                        placeholder="Enter secure password"
                        minLength={8}
                      />
                      <p className="form-help">Minimum 8 characters</p>
                    </div>

                    <div className="form-group">
                      <label className="form-label required">
                        Confirm Password
                      </label>
                      <input
                        type="password"
                        required
                        value={newUser.confirmPassword}
                        onChange={(e) => setNewUser(prev => ({ ...prev, confirmPassword: e.target.value }))}
                        className="form-input"
                        placeholder="Re-enter password"
                        minLength={8}
                      />
                      {newUser.password && newUser.confirmPassword && newUser.password !== newUser.confirmPassword && (
                        <p className="form-help" style={{ color: 'var(--error)' }}>Passwords do not match</p>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              <div className="modal-footer">
                <button
                  type="button"
                  onClick={() => setShowAddUserModal(false)}
                  className="btn-modal btn-modal-secondary"
                >
                  <X className="w-4 h-4" />
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting || (newUser.password && newUser.confirmPassword && newUser.password !== newUser.confirmPassword ? true : false)}
                  className="btn-modal btn-modal-primary"
                >
                  {isSubmitting ? (
                    <>
                      <div className="loading-spinner"></div>
                      Creating User...
                    </>
                  ) : (
                    <>
                      <Save className="w-4 h-4" />
                      Create User
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </>
      )}

      {/* View User Modal */}
      {showViewModal && selectedUser && (
        <>
          <div className="modal-overlay" onClick={() => setShowViewModal(false)} />
          <div className="modal">
            <div className="modal-header">
              <h2 className="modal-title">
                <Eye className="w-5 h-5" />
                User Details
              </h2>
              <button
                onClick={() => setShowViewModal(false)}
                className="btn-modal-close"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="modal-body">
              <div className="user-details-grid">
                <div className="user-avatar-section">
                  <div className="user-avatar-large">
                    {selectedUser.avatar ? (
                      <img src={selectedUser.avatar} alt={selectedUser.name} />
                    ) : (
                      <User className="w-12 h-12" />
                    )}
                  </div>
                  <div className="user-status-badge">
                    <span className={`status-indicator ${selectedUser.isActive ? 'active' : 'inactive'}`} />
                    {selectedUser.isActive ? 'Active' : 'Inactive'}
                  </div>
                </div>

                <div className="user-info-section">
                  <div className="info-group">
                    <h3 className="info-title">Basic Information</h3>
                    <div className="info-grid">
                      <div className="info-item">
                        <label>Name</label>
                        <p>{selectedUser.name}</p>
                      </div>
                      <div className="info-item">
                        <label>Email</label>
                        <p>{selectedUser.email}</p>
                      </div>
                      <div className="info-item">
                        <label>Phone</label>
                        <p>{selectedUser.phone || 'Not provided'}</p>
                      </div>
                      <div className="info-item">
                        <label>User ID</label>
                        <p className="text-xs">{selectedUser.id}</p>
                      </div>
                    </div>
                  </div>

                  <div className="info-group">
                    <h3 className="info-title">Roles & Permissions</h3>
                    <div className="roles-list">
                      {selectedUser.roles.map((role, index) => (
                        <span key={index} className="role-badge">
                          {role.role}
                        </span>
                      ))}
                    </div>
                  </div>

                  <div className="info-group">
                    <h3 className="info-title">Account Information</h3>
                    <div className="info-grid">
                      <div className="info-item">
                        <label>Status</label>
                        <p>
                          <span className={`status-badge ${selectedUser.isActive ? 'active' : 'inactive'}`}>
                            {selectedUser.isActive ? 'Active' : 'Inactive'}
                          </span>
                        </p>
                      </div>
                      <div className="info-item">
                        <label>Member Since</label>
                        <p>{new Date(selectedUser.createdAt).toLocaleDateString()}</p>
                      </div>
                    </div>
                  </div>

                  {selectedUser.specialization && (
                    <div className="info-group">
                      <h3 className="info-title">Professional Information</h3>
                      <div className="info-grid">
                        <div className="info-item">
                          <label>Specialization</label>
                          <p>{selectedUser.specialization}</p>
                        </div>
                        {selectedUser.experienceYears && (
                          <div className="info-item">
                            <label>Experience</label>
                            <p>{selectedUser.experienceYears} years</p>
                          </div>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>

            <div className="modal-footer">
              <button
                onClick={() => setShowViewModal(false)}
                className="btn-modal btn-modal-secondary"
              >
                Close
              </button>
              <button
                onClick={() => {
                  setShowViewModal(false);
                  handleEdit(selectedUser.id);
                }}
                className="btn-modal btn-modal-primary"
              >
                <Edit className="w-4 h-4" />
                Edit User
              </button>
            </div>
          </div>
        </>
      )}

      {/* Edit User Modal */}
      {showEditModal && selectedUser && (
        <>
          <div className="modal-overlay" onClick={() => setShowEditModal(false)} />
          <div className="modal">
            <div className="modal-header">
              <h2 className="modal-title">
                <Edit className="w-5 h-5" />
                Edit User
              </h2>
              <button
                onClick={() => setShowEditModal(false)}
                className="btn-modal-close"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <form onSubmit={handleEditSubmit}>
              <div className="modal-body">
                <div className="form-section">
                  <h3 className="form-section-title">
                    <User className="w-4 h-4" />
                    Basic Information
                  </h3>
                  <div className="form-grid">
                    <div className="form-group">
                      <label className="form-label required">
                        Name
                      </label>
                      <input
                        type="text"
                        name="name"
                        value={editFormData.name}
                        onChange={handleEditChange}
                        required
                        className="form-input"
                        placeholder="Enter full name"
                      />
                    </div>

                    <div className="form-group">
                      <label className="form-label required">
                        Email
                      </label>
                      <input
                        type="email"
                        name="email"
                        value={editFormData.email}
                        onChange={handleEditChange}
                        required
                        className="form-input"
                        placeholder="Enter email address"
                      />
                    </div>

                    <div className="form-group">
                      <label className="form-label">
                        Phone
                      </label>
                      <input
                        type="tel"
                        name="phone"
                        value={editFormData.phone}
                        onChange={handleEditChange}
                        className="form-input"
                        placeholder="Enter phone number"
                      />
                    </div>

                    <div className="form-group">
                      <label className="form-label">
                        Account Status
                      </label>
                      <div className="form-switch">
                        <label className="switch">
                          <input
                            type="checkbox"
                            name="isActive"
                            checked={editFormData.isActive}
                            onChange={handleEditChange}
                          />
                          <span className="slider"></span>
                        </label>
                        <span className="switch-label">
                          {editFormData.isActive ? 'Active' : 'Inactive'}
                        </span>
                      </div>
                      <p className="form-help">
                        Inactive users cannot log in or access the system
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="modal-footer">
                <button
                  type="button"
                  onClick={() => setShowEditModal(false)}
                  className="btn-modal btn-modal-secondary"
                >
                  <X className="w-4 h-4" />
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="btn-modal btn-modal-primary"
                >
                  {isSubmitting ? (
                    <>
                      <div className="loading-spinner"></div>
                      Saving...
                    </>
                  ) : (
                    <>
                      <Save className="w-4 h-4" />
                      Save Changes
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </>
      )}
    </div>
  );
}
