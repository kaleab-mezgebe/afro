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
  const [showRightSidebar, setShowRightSidebar] = useState(true);
  const [quickFilters, setQuickFilters] = useState<string[]>([]);
  const [showAddUserModal, setShowAddUserModal] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
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
      // The mock data fallback is preventing real updates from showing
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
      // Only use mock data as a last resort for development
      if (process.env.NODE_ENV === 'development') {
        const mockUsers = [
          {
            id: '1',
            email: 'james.smith0@example.com',
            name: 'James Smith',
            phone: '+12025551234',
            roles: [{ role: 'customer' }],
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          },
          {
            id: '2',
            email: 'mary.johnson1@example.com',
            name: 'Mary Johnson',
            phone: '+12025551235',
            roles: [{ role: 'customer' }],
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          },
          {
            id: '3',
            email: 'john.williams2@example.com',
            name: 'John Williams',
            phone: '+12025551236',
            roles: [{ role: 'customer' }],
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          },
          {
            id: '4',
            email: 'patricia.brown3@example.com',
            name: 'Patricia Brown',
            phone: '+12025551237',
            roles: [{ role: 'customer' }],
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          },
          {
            id: '5',
            email: 'robert.jones4@example.com',
            name: 'Robert Jones',
            phone: '+12025551238',
            roles: [{ role: 'customer' }],
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          },
          {
            id: '6',
            email: 'jennifer.garcia5@example.com',
            name: 'Jennifer Garcia',
            phone: '+12025551239',
            roles: [{ role: 'customer' }],
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          },
          {
            id: '7',
            email: 'michael.miller6@example.com',
            name: 'Michael Miller',
            phone: '+12025551240',
            roles: [{ role: 'customer' }],
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          },
          {
            id: '8',
            email: 'linda.davis7@example.com',
            name: 'Linda Davis',
            phone: '+12025551241',
            roles: [{ role: 'customer' }],
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          },
          {
            id: '9',
            email: 'william.rodriguez8@example.com',
            name: 'William Rodriguez',
            phone: '+12025551242',
            roles: [{ role: 'customer' }],
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          },
          {
            id: '10',
            email: 'elizabeth.martinez9@example.com',
            name: 'Elizabeth Martinez',
            phone: '+12025551243',
            roles: [{ role: 'customer' }],
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          },
          {
            id: '11',
            email: 'barber.james0@salon.com',
            name: 'James Elite',
            phone: '+12025551334',
            roles: [{ role: 'staff' }],
            specialization: 'barber',
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            experienceYears: 8,
            portfolioImages: []
          },
          {
            id: '12',
            email: 'barber.mary1@salon.com',
            name: 'Mary Style',
            phone: '+12025551335',
            roles: [{ role: 'staff' }],
            specialization: 'hair_stylist',
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            experienceYears: 12,
            portfolioImages: []
          },
          {
            id: '13',
            email: 'barber.john2@salon.com',
            name: 'John Classic',
            phone: '+12025551336',
            roles: [{ role: 'staff' }],
            specialization: 'barber',
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            experienceYears: 15,
            portfolioImages: []
          },
          {
            id: '14',
            email: 'barber.patricia3@salon.com',
            name: 'Patricia Glamour',
            phone: '+12025551337',
            roles: [{ role: 'staff' }],
            specialization: 'makeup_artist',
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            experienceYears: 10,
            portfolioImages: []
          },
          {
            id: '15',
            email: 'barber.robert4@salon.com',
            name: 'Robert Modern',
            phone: '+12025551338',
            roles: [{ role: 'staff' }],
            specialization: 'hair_stylist',
            isActive: true,
            createdAt: '2026-03-10T00:00:00Z',
            avatar: null,
            experienceYears: 6,
            portfolioImages: []
          },
          {
            id: '16',
            email: 'admin@afro.com',
            name: 'Super Admin',
            phone: null,
            roles: [{ role: 'admin' }],
            isActive: true,
            createdAt: '2026-03-09T00:00:00Z',
            avatar: null,
            specialization: null,
            experienceYears: null,
            portfolioImages: []
          }
        ];
        setUsers(mockUsers);
      }
    } finally {
      setLoading(false);
    }
  };

  const handleSuspend = async (userId: string) => {
    try {
      await api.suspendUser(userId);
      toast.success('User suspended');
      loadUsers();
    } catch (error) {
      toast.error('Failed to suspend user');
    }
  };

  const handleActivate = async (userId: string) => {
    try {
      await api.activateUser(userId);
      toast.success('User activated');
      loadUsers();
    } catch (error) {
      toast.error('Failed to activate user');
    }
  };

  const handleDelete = async (userId: string) => {
    if (confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
      try {
        await api.deleteUser(userId);
        toast.success('User deleted');
        loadUsers();
      } catch (error) {
        toast.error('Failed to delete user');
      }
    }
  };

  const handleExport = () => {
    toast('Exporting users data...');
    // Add export functionality here
  };

  const handleAddUser = () => {
    setShowAddUserModal(true);
  };

  const handleCreateUser = async () => {
    // Validation
    if (!newUser.name.trim()) {
      toast.error('Name is required');
      return;
    }
    if (!newUser.email.trim()) {
      toast.error('Email is required');
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
    if (newUser.password.length < 6) {
      toast.error('Password must be at least 6 characters');
      return;
    }

    setIsSubmitting(true);
    try {
      console.log('Creating user with data:', newUser);
      const userData = {
        name: newUser.name.trim(),
        email: newUser.email.trim(),
        phone: newUser.phone.trim() || null,
        password: newUser.password,
        roles: [newUser.role],
        specialization: newUser.role === 'staff' ? newUser.specialization : null,
        experienceYears: newUser.role === 'staff' ? newUser.experienceYears : null
      };

      console.log('Sending to API:', userData);
      const response = await api.createUser(userData);
      console.log('Create user response:', response);

      toast.success('User created successfully!');
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

      // Reload users to get the latest data from database
      await loadUsers();
    } catch (error: any) {
      console.error('Create user error:', error);
      const errorMessage = error.response?.data?.message || error.message || 'Failed to create user';
      toast.error(errorMessage);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleInputChange = (field: keyof NewUser, value: string | number | undefined) => {
    setNewUser(prev => ({ ...prev, [field]: value }));
  };

  const handleBulkAction = async (action: 'activate' | 'suspend' | 'delete') => {
    if (selectedUsers.length === 0) {
      toast.error('Please select users first');
      return;
    }

    if (action === 'delete' && !confirm(`Are you sure you want to delete ${selectedUsers.length} users?`)) {
      return;
    }

    try {
      for (const userId of selectedUsers) {
        if (action === 'activate') await api.activateUser(userId);
        else if (action === 'suspend') await api.suspendUser(userId);
        else if (action === 'delete') await api.deleteUser(userId);
      }
      toast.success(`${action} completed for ${selectedUsers.length} users`);
      setSelectedUsers([]);
      loadUsers();
    } catch (error) {
      toast.error(`Failed to ${action} users`);
    }
  };

  const filteredUsers = users.filter(user => {
    const matchesSearch = user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.phone?.includes(searchTerm);
    const matchesRole = roleFilter === 'all' || user.roles.some(r => r.role === roleFilter);
    const matchesStatus = statusFilter === 'all' ||
      (statusFilter === 'active' && user.isActive) ||
      (statusFilter === 'inactive' && !user.isActive);
    const matchesSpecialization = specializationFilter === 'all' ||
      user.specialization === specializationFilter;
    const matchesQuickFilters = quickFilters.length === 0 ||
      quickFilters.some(filter => {
        if (filter === 'new') {
          const joinDate = new Date(user.createdAt);
          const weekAgo = new Date();
          weekAgo.setDate(weekAgo.getDate() - 7);
          return joinDate > weekAgo;
        }
        if (filter === 'staff') return user.roles.some(r => r.role === 'staff');
        if (filter === 'customers') return user.roles.some(r => r.role === 'customer');
        if (filter === 'inactive') return !user.isActive;
        return false;
      });
    return matchesSearch && matchesRole && matchesStatus && matchesSpecialization && matchesQuickFilters;
  });

  const getRoleBadge = (roles: Array<{ role: string }>) => {
    const role = roles[0]?.role || 'unknown';
    const colors: Record<string, string> = {
      super_admin: 'badge-error',
      admin: 'badge-error',
      staff: 'badge-success',
      customer: 'badge-warning'
    };
    return colors[role] || 'badge-gray';
  };

  const getSpecializationBadge = (specialization?: string | null) => {
    if (!specialization) return null;

    const colors: Record<string, string> = {
      barber: 'badge-info',
      hair_stylist: 'badge-purple',
      makeup_artist: 'badge-pink',
      nail_technician: 'badge-blue',
      lash_technician: 'badge-indigo',
      spa_therapist: 'badge-green',
      esthetician: 'badge-teal'
    };

    const labels: Record<string, string> = {
      barber: 'Barber',
      hair_stylist: 'Hair Stylist',
      makeup_artist: 'Makeup Artist',
      nail_technician: 'Nail Tech',
      lash_technician: 'Lash Tech',
      spa_therapist: 'Spa Therapist',
      esthetician: 'Esthetician'
    };

    return (
      <span className={`badge ${colors[specialization] || 'badge-gray'} text-xs ml-2`}>
        {labels[specialization] || specialization}
      </span>
    );
  };

  const getUserStats = () => {
    const totalUsers = users.length;
    const activeUsers = users.filter(u => u.isActive).length;
    const staffUsers = users.filter(u => u.roles.some(r => r.role === 'staff')).length;
    const customerUsers = users.filter(u => u.roles.some(r => r.role === 'customer')).length;
    const newUsers = users.filter(u => {
      const joinDate = new Date(u.createdAt);
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      return joinDate > weekAgo;
    }).length;
    const inactiveUsers = users.filter(u => !u.isActive).length;

    return {
      total: totalUsers,
      active: activeUsers,
      staff: staffUsers,
      customers: customerUsers,
      new: newUsers,
      inactive: inactiveUsers
    };
  };

  const getRecentActivity = () => {
    return [
      { id: 1, title: 'New user registration', user: 'James Smith', time: '2 minutes ago', type: 'user', color: 'bg-green-100 text-green-600' },
      { id: 2, title: 'Staff member approved', user: 'Mary Style', time: '15 minutes ago', type: 'staff', color: 'bg-blue-100 text-blue-600' },
      { id: 3, title: 'User profile updated', user: 'John Williams', time: '1 hour ago', type: 'edit', color: 'bg-purple-100 text-purple-600' },
      { id: 4, title: 'Account suspended', user: 'Robert Jones', time: '2 hours ago', type: 'suspend', color: 'bg-red-100 text-red-600' },
      { id: 5, title: 'Password reset requested', user: 'Patricia Brown', time: '3 hours ago', type: 'security', color: 'bg-yellow-100 text-yellow-600' }
    ];
  };

  const toggleQuickFilter = (filter: string) => {
    setQuickFilters(prev =>
      prev.includes(filter)
        ? prev.filter(f => f !== filter)
        : [...prev, filter]
    );
  };

  const stats = getUserStats();
  const recentActivity = getRecentActivity();

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
      <div className="main-content">
        {/* Header */}
        <div className="header">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Beauty Professionals Management</h1>
            <p className="text-gray-600">Manage all users, staff, and beauty professionals</p>
          </div>
          <div className="flex gap-3">
            <button
              onClick={() => setShowRightSidebar(!showRightSidebar)}
              className="btn btn-secondary"
            >
              <Settings size={16} />
              {showRightSidebar ? 'Hide' : 'Show'} Panel
            </button>
            <button onClick={handleExport} className="btn btn-secondary">
              <Download size={16} />
              Export
            </button>
            <button onClick={handleAddUser} className="btn btn-primary">
              <UserPlus size={16} />
              Add User
            </button>
          </div>
        </div>

        {/* Filters */}
        <div className="card mb-6">
          <div className="flex flex-col lg:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <input
                type="text"
                placeholder="Search users by name, email, or phone..."
                className="input pl-10"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>

            <div className="flex items-center gap-2">
              <Filter size={20} className="text-gray-400" />
              <select
                className="input"
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value)}
              >
                <option value="all">All Roles</option>
                <option value="super_admin">Super Admin</option>
                <option value="admin">Admin</option>
                <option value="staff">Staff</option>
                <option value="customer">Customer</option>
              </select>
            </div>

            <div className="flex items-center gap-2">
              <select
                className="input"
                value={specializationFilter}
                onChange={(e) => setSpecializationFilter(e.target.value)}
              >
                <option value="all">All Specializations</option>
                <option value="barber">Barber</option>
                <option value="hair_stylist">Hair Stylist</option>
                <option value="makeup_artist">Makeup Artist</option>
                <option value="nail_technician">Nail Technician</option>
                <option value="lash_technician">Lash Technician</option>
                <option value="spa_therapist">Spa Therapist</option>
                <option value="esthetician">Esthetician</option>
              </select>
            </div>

            <div className="flex items-center gap-2">
              <select
                className="input"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                <option value="all">All Status</option>
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
          {selectedUsers.length > 0 && (
            <div className="mt-4 p-3 bg-gray-50 rounded-lg flex items-center justify-between">
              <span className="text-sm text-gray-600">
                {selectedUsers.length} users selected
              </span>
              <div className="flex gap-2">
                <button
                  onClick={() => handleBulkAction('activate')}
                  className="btn btn-secondary text-sm"
                >
                  <CheckCircle size={14} />
                  Activate
                </button>
                <button
                  onClick={() => handleBulkAction('suspend')}
                  className="btn btn-secondary text-sm"
                >
                  <Ban size={14} />
                  Suspend
                </button>
                <button
                  onClick={() => handleBulkAction('delete')}
                  className="btn btn-danger text-sm"
                >
                  <Trash2 size={14} />
                  Delete
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Users Table */}
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>
                  <input
                    type="checkbox"
                    onChange={(e) => {
                      if (e.target.checked) {
                        setSelectedUsers(filteredUsers.map(u => u.id));
                      } else {
                        setSelectedUsers([]);
                      }
                    }}
                    checked={selectedUsers.length === filteredUsers.length && filteredUsers.length > 0}
                  />
                </th>
                <th>User</th>
                <th>Role</th>
                <th>Specialization</th>
                <th>Status</th>
                <th>Joined Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-8 text-gray-500">
                    No users found
                  </td>
                </tr>
              ) : (
                filteredUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-gray-50 transition-colors">
                    <td>
                      <input
                        type="checkbox"
                        checked={selectedUsers.includes(user.id)}
                        onChange={(e) => {
                          if (e.target.checked) {
                            setSelectedUsers([...selectedUsers, user.id]);
                          } else {
                            setSelectedUsers(selectedUsers.filter(id => id !== user.id));
                          }
                        }}
                      />
                    </td>
                    <td>
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-primary bg-opacity-10 rounded-full flex items-center justify-center">
                          {user.avatar ? (
                            <img src={user.avatar} alt={user.name} className="w-full h-full rounded-full object-cover" />
                          ) : (
                            <UserPlus size={20} className="text-primary" />
                          )}
                        </div>
                        <div>
                          <p className="font-medium text-gray-900">{user.name}</p>
                          <div className="flex items-center gap-2 text-sm text-gray-500">
                            <Mail size={12} />
                            {user.email}
                          </div>
                          {user.phone ? (
                            <div className="flex items-center gap-2 text-sm text-gray-500">
                              <Phone size={12} />
                              {user.phone}
                            </div>
                          ) : null}
                        </div>
                      </div>
                    </td>
                    <td>
                      <span className={`badge ${getRoleBadge(user.roles)}`}>
                        {user.roles[0]?.role || 'Unknown'}
                      </span>
                    </td>
                    <td>
                      {getSpecializationBadge(user.specialization)}
                      {user.experienceYears && (
                        <span className="text-xs text-gray-500 ml-2">
                          {user.experienceYears} years
                        </span>
                      )}
                    </td>
                    <td>
                      <span className={`badge ${user.isActive ? 'badge-success' : 'badge-error'}`}>
                        {user.isActive ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td>
                      <div className="flex items-center gap-1 text-sm text-gray-500">
                        <Calendar size={14} />
                        {new Date(user.createdAt).toLocaleDateString()}
                      </div>
                    </td>
                    <td>
                      <div className="relative">
                        <button
                          onClick={() => setShowDropdown(showDropdown === user.id ? null : user.id)}
                          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                        >
                          <MoreVertical size={16} />
                        </button>

                        {showDropdown === user.id && (
                          <div className="dropdown">
                            <button
                              onClick={() => {
                                setShowDropdown(null);
                                toast(`Viewing profile for ${user.name}`);
                              }}
                              className="dropdown-item"
                            >
                              <Eye size={16} />
                              View Profile
                            </button>
                            <button
                              onClick={() => {
                                setShowDropdown(null);
                                toast(`Editing user ${user.name}`);
                              }}
                              className="dropdown-item"
                            >
                              <Edit size={16} />
                              Edit User
                            </button>
                            <button
                              onClick={() => {
                                setShowDropdown(null);
                                toast(`Password reset sent to ${user.email}`);
                              }}
                              className="dropdown-item"
                            >
                              <Mail size={16} />
                              Reset Password
                            </button>
                            {user.roles[0]?.role === 'staff' && (
                              <>
                                <div className="dropdown-divider" />
                                <button
                                  onClick={() => {
                                    setShowDropdown(null);
                                    toast(`Viewing ${user.name}'s portfolio`);
                                  }}
                                  className="dropdown-item"
                                >
                                  <Camera size={16} />
                                  View Portfolio
                                </button>
                                <button
                                  onClick={() => {
                                    setShowDropdown(null);
                                    toast(`Editing ${user.name}'s specialization`);
                                  }}
                                  className="dropdown-item"
                                >
                                  <Briefcase size={16} />
                                  Edit Specialization
                                </button>
                              </>
                            )}
                            <div className="dropdown-divider" />
                            {user.isActive ? (
                              <button
                                onClick={() => {
                                  handleSuspend(user.id);
                                  setShowDropdown(null);
                                }}
                                className="dropdown-item text-yellow-600"
                              >
                                <Ban size={16} />
                                Suspend
                              </button>
                            ) : (
                              <button
                                onClick={() => {
                                  handleActivate(user.id);
                                  setShowDropdown(null);
                                }}
                                className="dropdown-item text-green-600"
                              >
                                <CheckCircle size={16} />
                                Activate
                              </button>
                            )}
                            <button
                              onClick={() => {
                                handleDelete(user.id);
                                setShowDropdown(null);
                              }}
                              className="dropdown-item text-red-600"
                            >
                              <Trash2 size={16} />
                              Delete
                            </button>
                          </div>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add User Modal */}
      {showAddUserModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto m-4">
            {/* Modal Header */}
            <div className="flex items-center justify-between p-6 border-b border-gray-200">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-primary bg-opacity-10 rounded-full flex items-center justify-center">
                  <UserPlus size={24} className="text-primary" />
                </div>
                <div>
                  <h2 className="text-xl font-bold text-gray-900">Add New User</h2>
                  <p className="text-sm text-gray-500">Create a new user account</p>
                </div>
              </div>
              <button
                onClick={() => setShowAddUserModal(false)}
                className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
              >
                <X size={20} className="text-gray-500" />
              </button>
            </div>

            {/* Modal Body */}
            <div className="p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Name */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <User size={16} className="inline mr-1" />
                    Full Name *
                  </label>
                  <input
                    type="text"
                    value={newUser.name}
                    onChange={(e) => handleInputChange('name', e.target.value)}
                    className="input"
                    placeholder="Enter full name"
                  />
                </div>

                {/* Email */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <Mail size={16} className="inline mr-1" />
                    Email Address *
                  </label>
                  <input
                    type="email"
                    value={newUser.email}
                    onChange={(e) => handleInputChange('email', e.target.value)}
                    className="input"
                    placeholder="user@example.com"
                  />
                </div>

                {/* Phone */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <Phone size={16} className="inline mr-1" />
                    Phone Number
                  </label>
                  <input
                    type="tel"
                    value={newUser.phone}
                    onChange={(e) => handleInputChange('phone', e.target.value)}
                    className="input"
                    placeholder="+1234567890"
                  />
                </div>

                {/* Role */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <Briefcase size={16} className="inline mr-1" />
                    Role *
                  </label>
                  <select
                    value={newUser.role}
                    onChange={(e) => handleInputChange('role', e.target.value)}
                    className="input"
                  >
                    <option value="customer">Customer</option>
                    <option value="staff">Staff Member</option>
                    <option value="admin">Admin</option>
                  </select>
                </div>

                {/* Specialization (only for staff) */}
                {newUser.role === 'staff' && (
                  <>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        <Award size={16} className="inline mr-1" />
                        Specialization
                      </label>
                      <select
                        value={newUser.specialization}
                        onChange={(e) => handleInputChange('specialization', e.target.value)}
                        className="input"
                      >
                        <option value="">Select Specialization</option>
                        <option value="barber">Barber</option>
                        <option value="hair_stylist">Hair Stylist</option>
                        <option value="makeup_artist">Makeup Artist</option>
                        <option value="nail_technician">Nail Technician</option>
                        <option value="lash_technician">Lash Technician</option>
                        <option value="spa_therapist">Spa Therapist</option>
                        <option value="esthetician">Esthetician</option>
                      </select>
                    </div>

                    {/* Experience Years */}
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        <Calendar size={16} className="inline mr-1" />
                        Years of Experience
                      </label>
                      <input
                        type="number"
                        min="0"
                        max="50"
                        value={newUser.experienceYears || ''}
                        onChange={(e) => {
                          const value = e.target.value;
                          if (value === '') {
                            handleInputChange('experienceYears', undefined);
                          } else {
                            const parsed = parseInt(value);
                            handleInputChange('experienceYears', isNaN(parsed) ? undefined : parsed);
                          }
                        }}
                        className="input"
                        placeholder="Years of experience"
                      />
                    </div>
                  </>
                )}

                {/* Password */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <Lock size={16} className="inline mr-1" />
                    Password *
                  </label>
                  <input
                    type="password"
                    value={newUser.password}
                    onChange={(e) => handleInputChange('password', e.target.value)}
                    className="input"
                    placeholder="Min. 6 characters"
                  />
                </div>

                {/* Confirm Password */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <Lock size={16} className="inline mr-1" />
                    Confirm Password *
                  </label>
                  <input
                    type="password"
                    value={newUser.confirmPassword}
                    onChange={(e) => handleInputChange('confirmPassword', e.target.value)}
                    className="input"
                    placeholder="Re-enter password"
                  />
                </div>
              </div>

              {/* Account Status Info */}
              <div className="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
                <div className="flex items-start gap-3">
                  <AlertCircle size={20} className="text-blue-600 mt-0.5" />
                  <div>
                    <h4 className="font-medium text-blue-900">Account Information</h4>
                    <p className="text-sm text-blue-700 mt-1">
                      The new account will be created as <strong>Active</strong> by default.
                      You can change the status later from the user management panel.
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="flex items-center justify-end gap-3 p-6 border-t border-gray-200">
              <button
                onClick={() => setShowAddUserModal(false)}
                className="btn btn-secondary"
                disabled={isSubmitting}
              >
                Cancel
              </button>
              <button
                onClick={handleCreateUser}
                className="btn btn-primary"
                disabled={isSubmitting}
              >
                {isSubmitting ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Creating...
                  </>
                ) : (
                  <>
                    <Save size={16} />
                    Create User
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Right Sidebar */}
      {showRightSidebar && (
        <div className="right-sidebar">
          {/* Quick Stats */}
          <div className="right-sidebar-section">
            <h3 className="right-sidebar-title">
              <BarChart3 size={18} />
              Quick Statistics
            </h3>
            <div className="quick-stat">
              <span className="quick-stat-label">Total Users</span>
              <span className="quick-stat-value">{stats.total}</span>
            </div>
            <div className="quick-stat">
              <span className="quick-stat-label">Active Users</span>
              <span className="quick-stat-value text-green-600">{stats.active}</span>
            </div>
            <div className="quick-stat">
              <span className="quick-stat-label">Staff Members</span>
              <span className="quick-stat-value text-blue-600">{stats.staff}</span>
            </div>
            <div className="quick-stat">
              <span className="quick-stat-label">Customers</span>
              <span className="quick-stat-value text-purple-600">{stats.customers}</span>
            </div>
            <div className="quick-stat">
              <span className="quick-stat-label">New This Week</span>
              <span className="quick-stat-value text-orange-600">{stats.new}</span>
            </div>
            <div className="quick-stat">
              <span className="quick-stat-label">Inactive</span>
              <span className="quick-stat-value text-red-600">{stats.inactive}</span>
            </div>
          </div>

          {/* Quick Filters */}
          <div className="right-sidebar-section">
            <h3 className="right-sidebar-title">
              <Filter size={18} />
              Quick Filters
            </h3>
            <div className="flex flex-wrap">
              <button
                onClick={() => toggleQuickFilter('new')}
                className={`filter-chip ${quickFilters.includes('new') ? 'active' : ''}`}
              >
                <Clock size={12} />
                New Users
              </button>
              <button
                onClick={() => toggleQuickFilter('staff')}
                className={`filter-chip ${quickFilters.includes('staff') ? 'active' : ''}`}
              >
                <Briefcase size={12} />
                Staff
              </button>
              <button
                onClick={() => toggleQuickFilter('customers')}
                className={`filter-chip ${quickFilters.includes('customers') ? 'active' : ''}`}
              >
                <Users size={12} />
                Customers
              </button>
              <button
                onClick={() => toggleQuickFilter('inactive')}
                className={`filter-chip ${quickFilters.includes('inactive') ? 'active' : ''}`}
              >
                <AlertCircle size={12} />
                Inactive
              </button>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="right-sidebar-section">
            <h3 className="right-sidebar-title">
              <Activity size={18} />
              Quick Actions
            </h3>
            <button
              onClick={handleAddUser}
              className="quick-action-btn primary"
            >
              <UserPlus size={16} />
              Add New User
            </button>
            <button
              onClick={() => toast('Opening bulk import...')}
              className="quick-action-btn"
            >
              <Download size={16} />
              Bulk Import Users
            </button>
            <button
              onClick={() => toast('Sending notifications...')}
              className="quick-action-btn"
            >
              <Mail size={16} />
              Send Notifications
            </button>
            <button
              onClick={() => toast('Generating report...')}
              className="quick-action-btn"
            >
              <BarChart3 size={16} />
              Generate Report
            </button>
            <button
              onClick={() => toast('Opening settings...')}
              className="quick-action-btn"
            >
              <Settings size={16} />
              User Settings
            </button>
          </div>

          {/* Recent Activity */}
          <div className="right-sidebar-section">
            <h3 className="right-sidebar-title">
              <Clock size={18} />
              Recent Activity
            </h3>
            <div className="space-y-2">
              {recentActivity.map((activity) => (
                <div key={activity.id} className="activity-item">
                  <div className={`activity-icon ${activity.color}`}>
                    {activity.type === 'user' && <UserPlus size={16} />}
                    {activity.type === 'staff' && <CheckCircle size={16} />}
                    {activity.type === 'edit' && <Edit size={16} />}
                    {activity.type === 'suspend' && <Ban size={16} />}
                    {activity.type === 'security' && <AlertCircle size={16} />}
                  </div>
                  <div className="activity-content">
                    <div className="activity-title">{activity.title}</div>
                    <div className="text-xs text-gray-500">{activity.user}</div>
                    <div className="activity-time">{activity.time}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Top Performers */}
          <div className="right-sidebar-section">
            <h3 className="right-sidebar-title">
              <Star size={18} />
              Top Performers
            </h3>
            <div className="space-y-2">
              {users
                .filter(u => u.roles.some(r => r.role === 'staff'))
                .slice(0, 3)
                .map((user) => (
                  <div key={user.id} className="flex items-center gap-3 p-2 bg-gray-50 rounded-lg">
                    <div className="w-8 h-8 bg-primary bg-opacity-10 rounded-full flex items-center justify-center">
                      <Award size={14} className="text-primary" />
                    </div>
                    <div className="flex-1">
                      <div className="text-sm font-medium">{user.name}</div>
                      <div className="text-xs text-gray-500">
                        {user.specialization && `${user.specialization.replace('_', ' ')} • `}
                        {user.experienceYears ? `${user.experienceYears} years` : 'Experienced'}
                      </div>
                    </div>
                  </div>
                ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
