'use client';

import { useEffect, useState } from 'react';
import Sidebar from '@/components/Sidebar';
import { api } from '@/lib/api';
import toast from 'react-hot-toast';
import { useAuth } from '@/hooks/useAuth';
import {
  Scissors,
  Search,
  Plus,
  MoreVertical,
  Edit,
  Trash2,
  Filter,
  Eye,
  X,
  Save,
  Clock,
  DollarSign
} from 'lucide-react';

interface Service {
  id: string;
  name: string;
  description: string;
  price: number;
  duration: number;
  category: string;
  targetGender: string;
  isActive: boolean;
  image?: string;
}

export default function ServicesPage() {
  const { loading: authLoading, authenticated } = useAuth();
  const [services, setServices] = useState<Service[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [genderFilter, setGenderFilter] = useState('all');

  const [showAddModal, setShowAddModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [selectedService, setSelectedService] = useState<Service | null>(null);
  const [showDropdown, setShowDropdown] = useState<{ id: string; x: number; y: number } | null>(null);

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: '',
    duration: '',
    category: 'haircut',
    targetGender: 'unisex',
    isActive: true
  });

  useEffect(() => {
    if (authenticated) {
      loadServices();
    }
  }, [authenticated]);

  useEffect(() => {
    const handleScroll = () => {
      if (showDropdown) setShowDropdown(null);
    };
    window.addEventListener('scroll', handleScroll, true);
    return () => window.removeEventListener('scroll', handleScroll, true);
  }, [showDropdown]);

  const loadServices = async () => {
    try {
      const response = await api.getServices();
      if (response.data) {
        setServices(response.data);
      }
    } catch (error) {
      console.error('Error loading services:', error);
      toast.error('Failed to load services');
      // For demonstration if API fails, load empty array
      setServices([]);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim() || !formData.price || !formData.duration) {
      toast.error('Please fill in all required fields');
      return;
    }

    setIsSubmitting(true);
    try {
      await api.createService({
        name: formData.name.trim(),
        description: formData.description.trim(),
        price: parseFloat(formData.price),
        duration: parseInt(formData.duration),
        category: formData.category,
        targetGender: formData.targetGender,
        isActive: formData.isActive
      });

      toast.success('Service created successfully');
      setShowAddModal(false);
      resetForm();
      loadServices();
    } catch (error: any) {
      console.error('Create service error:', error);
      toast.error(error.response?.data?.message || 'Failed to create service');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedService || !formData.name.trim() || !formData.price || !formData.duration) return;

    setIsSubmitting(true);
    try {
      await api.updateService(selectedService.id, {
        name: formData.name.trim(),
        description: formData.description.trim(),
        price: parseFloat(formData.price),
        duration: parseInt(formData.duration),
        category: formData.category,
        targetGender: formData.targetGender,
        isActive: formData.isActive
      });

      toast.success('Service updated successfully');
      setShowEditModal(false);
      setSelectedService(null);
      loadServices();
    } catch (error: any) {
      console.error('Edit service error:', error);
      toast.error(error.response?.data?.message || 'Failed to update service');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this service?')) return;
    try {
      await api.deleteService(id);
      toast.success('Service deleted successfully');
      setShowDropdown(null);
      loadServices();
    } catch (error) {
      console.error('Delete service error:', error);
      toast.error('Failed to delete service');
    }
  };

  const openEditModal = (service: Service) => {
    setSelectedService(service);
    setFormData({
      name: service.name,
      description: service.description || '',
      price: service.price.toString(),
      duration: service.duration.toString(),
      category: service.category || 'haircut',
      targetGender: service.targetGender || 'unisex',
      isActive: service.isActive !== false
    });
    setShowDropdown(null);
    setShowEditModal(true);
  };

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      price: '',
      duration: '',
      category: 'haircut',
      targetGender: 'unisex',
      isActive: true
    });
  };

  const filteredServices = services.filter(service => {
    const matchesSearch = searchTerm === '' ||
      service.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = categoryFilter === 'all' || service.category === categoryFilter;
    const matchesGender = genderFilter === 'all' || service.targetGender === genderFilter;

    return matchesSearch && matchesCategory && matchesGender;
  });

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
            <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
              <Scissors className="w-6 h-6 text-primary" />
              Services Menu
            </h1>
            <p className="text-gray-600">Manage haircuts, styling, and salon offerings</p>
          </div>
          <button
            onClick={() => { resetForm(); setShowAddModal(true); }}
            className="btn btn-primary"
          >
            <Plus className="w-4 h-4" />
            Add Service
          </button>
        </div>

        {/* Filters */}
        <div className="card">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Search services..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input pl-10"
              />
            </div>
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="input"
            >
              <option value="all">All Categories</option>
              <option value="haircut">Haircuts</option>
              <option value="styling">Styling & Color</option>
              <option value="grooming">Beard & Grooming</option>
              <option value="nails">Nails & Spa</option>
              <option value="massage">Massage Therapy</option>
            </select>
            <select
              value={genderFilter}
              onChange={(e) => setGenderFilter(e.target.value)}
              className="input"
            >
              <option value="all">Any Target Identity</option>
              <option value="male">Male Focus</option>
              <option value="female">Female Focus</option>
              <option value="unisex">Unisex</option>
            </select>
          </div>
        </div>

        {/* Services Grid/Table */}
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Service Details</th>
                <th>Category</th>
                <th>Audience</th>
                <th>Price & Time</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredServices.length > 0 ? (
                filteredServices.map(service => (
                  <tr key={service.id}>
                    <td>
                      <div>
                        <p className="font-semibold text-gray-900">{service.name}</p>
                        <p className="text-sm text-gray-500 truncate max-w-xs">{service.description || 'No description provided'}</p>
                      </div>
                    </td>
                    <td>
                      <span className="badge badge-info uppercase text-xs tracking-wider">
                        {service.category || 'Standard'}
                      </span>
                    </td>
                    <td>
                      <span className={`badge ${service.targetGender === 'male' ? 'bg-blue-100 text-blue-800' : service.targetGender === 'female' ? 'bg-pink-100 text-pink-800' : 'badge-success'}`}>
                        {service.targetGender || 'Unisex'}
                      </span>
                    </td>
                    <td>
                      <div className="flex flex-col gap-1">
                        <span className="font-semibold text-gray-900 flex items-center gap-1">
                          <DollarSign className="w-3 h-3 text-medium" />{service.price}
                        </span>
                        <span className="text-sm text-gray-500 flex items-center gap-1">
                          <Clock className="w-3 h-3 text-medium" />{service.duration} min
                        </span>
                      </div>
                    </td>
                    <td>
                      <span className={`badge ${service.isActive !== false ? 'badge-success' : 'badge-warning'}`}>
                        {service.isActive !== false ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td>
                      <button
                        onClick={(e) => {
                          if (showDropdown?.id === service.id) {
                            setShowDropdown(null);
                          } else {
                            const rect = e.currentTarget.getBoundingClientRect();
                            setShowDropdown({
                              id: service.id,
                              x: rect.right - 180,
                              y: rect.bottom + 8,
                            });
                          }
                        }}
                        className="btn btn-secondary p-2"
                      >
                        <MoreVertical className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={6} className="text-center py-12 text-gray-500">
                    <Scissors className="w-12 h-12 mx-auto text-gray-300 mb-4" />
                    <p className="text-lg font-medium">No services found</p>
                    <p className="text-sm">Try adjusting your filters or add a new service.</p>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Dynamic Dropdown Menu */}
        {showDropdown && (
          <>
            <div className="fixed inset-0 z-40" onClick={() => setShowDropdown(null)} />
            <div
              className="dropdown fixed z-50 m-0"
              style={{ top: Math.min(showDropdown.y, window.innerHeight - 150), left: Math.max(0, showDropdown.x) }}
            >
              <button
                onClick={() => openEditModal(services.find(s => s.id === showDropdown.id)!)}
                className="dropdown-item"
              >
                <Edit className="w-4 h-4" /> Edit Service
              </button>
              <div className="dropdown-divider"></div>
              <button onClick={() => handleDelete(showDropdown.id)} className="dropdown-item text-red-600">
                <Trash2 className="w-4 h-4" /> Delete
              </button>
            </div>
          </>
        )}
      </div>

      {/* Add / Edit Modal */}
      {(showAddModal || showEditModal) && (
        <div className="fixed inset-0 z-[9999] flex items-center justify-center bg-black bg-opacity-50 backdrop-blur-sm p-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden flex flex-col max-h-[90vh]">
            <div className="p-6 border-b border-gray-100 flex items-center justify-between sticky top-0 bg-white z-10">
              <h2 className="text-xl font-bold flex items-center gap-2">
                <Scissors className="w-5 h-5 text-primary" />
                {showAddModal ? 'Create New Service' : 'Edit Service'}
              </h2>
              <button onClick={() => { setShowAddModal(false); setShowEditModal(false); }} className="text-gray-400 hover:text-gray-600 transition-colors">
                <X className="w-6 h-6" />
              </button>
            </div>

            <div className="p-6 overflow-y-auto">
              <form id="serviceForm" onSubmit={showAddModal ? handleCreateSubmit : handleEditSubmit} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="flex flex-col gap-2 md:col-span-2">
                    <label className="font-semibold text-sm text-gray-700">Service Name <span className="text-red-500">*</span></label>
                    <input
                      type="text" required
                      className="input" placeholder="e.g. Classic Men's Fade"
                      value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })}
                    />
                  </div>

                  <div className="flex flex-col gap-2 md:col-span-2">
                    <label className="font-semibold text-sm text-gray-700">Description</label>
                    <textarea
                      rows={3}
                      className="input resize-none" placeholder="Describe the service..."
                      value={formData.description} onChange={e => setFormData({ ...formData, description: e.target.value })}
                    />
                  </div>

                  <div className="flex flex-col gap-2">
                    <label className="font-semibold text-sm text-gray-700">Price ($) <span className="text-red-500">*</span></label>
                    <div className="relative">
                      <DollarSign className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                      <input
                        type="number" step="0.01" min="0" required
                        className="input pl-10" placeholder="0.00"
                        value={formData.price} onChange={e => setFormData({ ...formData, price: e.target.value })}
                      />
                    </div>
                  </div>

                  <div className="flex flex-col gap-2">
                    <label className="font-semibold text-sm text-gray-700">Duration (Minutes) <span className="text-red-500">*</span></label>
                    <div className="relative">
                      <Clock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                      <input
                        type="number" min="5" step="5" required
                        className="input pl-10" placeholder="45"
                        value={formData.duration} onChange={e => setFormData({ ...formData, duration: e.target.value })}
                      />
                    </div>
                  </div>

                  <div className="flex flex-col gap-2">
                    <label className="font-semibold text-sm text-gray-700">Category</label>
                    <select className="input" value={formData.category} onChange={e => setFormData({ ...formData, category: e.target.value })}>
                      <option value="haircut">Haircuts</option>
                      <option value="styling">Styling & Color</option>
                      <option value="grooming">Beard & Grooming</option>
                      <option value="nails">Nails & Spa</option>
                      <option value="massage">Massage Therapy</option>
                    </select>
                  </div>

                  <div className="flex flex-col gap-2">
                    <label className="font-semibold text-sm text-gray-700">Target Audience</label>
                    <select className="input" value={formData.targetGender} onChange={e => setFormData({ ...formData, targetGender: e.target.value })}>
                      <option value="unisex">Unisex</option>
                      <option value="male">Male Focus</option>
                      <option value="female">Female Focus</option>
                    </select>
                  </div>

                  <div className="flex items-center gap-3 md:col-span-2 pt-2 border-t border-gray-100">
                    <div className="relative inline-block w-12 h-6 align-middle select-none transition duration-200 ease-in">
                      <input
                        type="checkbox" id="toggle"
                        className="toggle-checkbox absolute block w-6 h-6 rounded-full bg-white border-4 appearance-none cursor-pointer"
                        checked={formData.isActive}
                        onChange={e => setFormData({ ...formData, isActive: e.target.checked })}
                        style={{ right: formData.isActive ? '0' : 'auto', left: formData.isActive ? 'auto' : '0', borderColor: formData.isActive ? '#10B981' : '#E5E7EB' }}
                      />
                      <label htmlFor="toggle" className={`toggle-label block overflow-hidden h-6 rounded-full cursor-pointer ${formData.isActive ? 'bg-success' : 'bg-gray-300'}`}></label>
                    </div>
                    <label htmlFor="toggle" className="text-sm text-gray-700 font-medium cursor-pointer">Service is Active (Available for booking)</label>
                  </div>
                </div>
              </form>
            </div>

            <div className="p-6 bg-gray-50 border-t border-gray-100 flex justify-end gap-3 sticky bottom-0">
              <button
                type="button"
                onClick={() => { setShowAddModal(false); setShowEditModal(false); }}
                className="btn btn-secondary px-6"
              >
                Cancel
              </button>
              <button
                type="submit"
                form="serviceForm"
                disabled={isSubmitting}
                className="btn btn-primary px-8 flex items-center justify-center min-w-[120px]"
              >
                {isSubmitting ? (
                  <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                ) : (
                  <><Save className="w-4 h-4 mr-2" /> Save Service</>
                )}
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
