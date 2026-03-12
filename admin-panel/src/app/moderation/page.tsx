'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Badge } from '@/components/ui/Badge'
import { AlertTriangle, Eye, Trash2, Check, X, Search, Filter, Flag, MessageSquare, Image, User } from 'lucide-react'

interface ReportedItem {
  id: string
  type: 'user' | 'review' | 'service' | 'photo'
  reportedBy: string
  reportedAt: string
  reason: string
  description: string
  status: 'pending' | 'reviewing' | 'resolved' | 'dismissed'
  targetId: string
  targetData: {
    name?: string
    content?: string
    imageUrl?: string
    userName?: string
    userEmail?: string
  }
  priority: 'low' | 'medium' | 'high'
}

export default function ContentModeration() {
  const [reportedItems, setReportedItems] = useState<ReportedItem[]>([])
  const [filter, setFilter] = useState<string>('all')
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedItem, setSelectedItem] = useState<ReportedItem | null>(null)

  useEffect(() => {
    // Mock data - replace with actual API call
    setReportedItems([
      {
        id: 'report_001',
        type: 'review',
        reportedBy: 'John Doe',
        reportedAt: '2024-01-15T10:30:00Z',
        reason: 'Inappropriate language',
        description: 'The review contains offensive and inappropriate language that violates our community guidelines.',
        status: 'pending',
        targetId: 'review_123',
        targetData: {
          name: 'Sarah Johnson',
          content: 'This service was terrible and the provider was unprofessional...'
        },
        priority: 'high'
      },
      {
        id: 'report_002',
        type: 'user',
        reportedBy: 'Jane Smith',
        reportedAt: '2024-01-14T15:45:00Z',
        reason: 'Fake profile',
        description: 'This user appears to be using fake information and may be a scam.',
        status: 'reviewing',
        targetId: 'user_456',
        targetData: {
          userName: 'Michael Brown',
          userEmail: 'michael.brown@email.com'
        },
        priority: 'medium'
      },
      {
        id: 'report_003',
        type: 'photo',
        reportedBy: 'Admin',
        reportedAt: '2024-01-13T09:15:00Z',
        reason: 'Inappropriate content',
        description: 'Photo contains inappropriate content not suitable for the platform.',
        status: 'pending',
        targetId: 'photo_789',
        targetData: {
          imageUrl: '/images/reported-photo.jpg'
        },
        priority: 'high'
      }
    ])
  }, [])

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800'
      case 'reviewing': return 'bg-blue-100 text-blue-800'
      case 'resolved': return 'bg-green-100 text-green-800'
      case 'dismissed': return 'bg-gray-100 text-gray-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'user': return <User className="w-4 h-4" />
      case 'review': return <MessageSquare className="w-4 h-4" />
      case 'photo': return <Image className="w-4 h-4" />
      default: return <Flag className="w-4 h-4" />
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high': return 'bg-red-100 text-red-800'
      case 'medium': return 'bg-orange-100 text-orange-800'
      case 'low': return 'bg-blue-100 text-blue-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const filteredItems = reportedItems.filter(item => {
    const matchesFilter = filter === 'all' || item.status === filter || item.type === filter || item.priority === filter
    const matchesSearch = item.reason.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         item.reportedBy.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         item.targetData.name?.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesFilter && matchesSearch
  })

  const handleAction = (itemId: string, action: 'approve' | 'dismiss' | 'remove') => {
    setReportedItems(prev => prev.map(item => 
      item.id === itemId 
        ? { ...item, status: action === 'dismiss' ? 'dismissed' : 'resolved' }
        : item
    ))
    setSelectedItem(null)
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Content Moderation</h1>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              <AlertTriangle className="w-4 h-4" />
              Pending Reviews
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {reportedItems.filter(item => item.status === 'pending').length}
            </div>
            <p className="text-xs text-muted-foreground">Need attention</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Under Review</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {reportedItems.filter(item => item.status === 'reviewing').length}
            </div>
            <p className="text-xs text-muted-foreground">Being processed</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">High Priority</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">
              {reportedItems.filter(item => item.priority === 'high').length}
            </div>
            <p className="text-xs text-muted-foreground">Immediate action needed</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Resolved Today</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">12</div>
            <p className="text-xs text-muted-foreground">+8% from yesterday</p>
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="flex gap-2 flex-wrap">
          <Button
            variant={filter === 'all' ? 'primary' : 'outline'}
            size="sm"
            onClick={() => setFilter('all')}
          >
            All
          </Button>
          <Button
            variant={filter === 'pending' ? 'primary' : 'outline'}
            size="sm"
            onClick={() => setFilter('pending')}
          >
            Pending
          </Button>
          <Button
            variant={filter === 'high' ? 'primary' : 'outline'}
            size="sm"
            onClick={() => setFilter('high')}
          >
            High Priority
          </Button>
          <Button
            variant={filter === 'user' ? 'primary' : 'outline'}
            size="sm"
            onClick={() => setFilter('user')}
          >
            Users
          </Button>
          <Button
            variant={filter === 'review' ? 'primary' : 'outline'}
            size="sm"
            onClick={() => setFilter('review')}
          >
            Reviews
          </Button>
          <Button
            variant={filter === 'photo' ? 'primary' : 'outline'}
            size="sm"
            onClick={() => setFilter('photo')}
          >
            Photos
          </Button>
        </div>
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Search reports..."
            className="w-full pl-10 pr-4 py-2 border rounded-lg"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Reports List */}
        <div className="lg:col-span-2 space-y-4">
          {filteredItems.map((item) => (
            <Card 
              key={item.id} 
              className={`cursor-pointer transition-all ${
                selectedItem?.id === item.id ? 'ring-2 ring-blue-500' : ''
              }`}
              onClick={() => setSelectedItem(item)}
            >
              <CardContent className="p-6">
                <div className="flex justify-between items-start mb-3">
                  <div className="flex items-center gap-2">
                    {getTypeIcon(item.type)}
                    <span className="font-semibold capitalize">{item.type}</span>
                    <Badge className={getStatusColor(item.status)}>
                      {item.status}
                    </Badge>
                    <Badge className={getPriorityColor(item.priority)}>
                      {item.priority}
                    </Badge>
                  </div>
                  <span className="text-sm text-gray-500">
                    {new Date(item.reportedAt).toLocaleDateString()}
                  </span>
                </div>
                
                <div className="mb-3">
                  <p className="font-medium text-sm mb-1">{item.reason}</p>
                  <p className="text-sm text-gray-600 line-clamp-2">{item.description}</p>
                </div>
                
                <div className="flex justify-between items-center">
                  <p className="text-sm text-gray-500">
                    Reported by <span className="font-medium">{item.reportedBy}</span>
                  </p>
                  <div className="flex gap-2">
                    <Button 
                      variant="outline" 
                      size="sm"
                      onClick={(e) => {
                        e.stopPropagation()
                        setSelectedItem(item)
                      }}
                    >
                      <Eye className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Detail Panel */}
        <div className="lg:col-span-1">
          {selectedItem ? (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  {getTypeIcon(selectedItem.type)}
                  Report Details
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <p className="text-sm font-medium mb-1">Type</p>
                  <p className="capitalize">{selectedItem.type}</p>
                </div>
                
                <div>
                  <p className="text-sm font-medium mb-1">Status</p>
                  <Badge className={getStatusColor(selectedItem.status)}>
                    {selectedItem.status}
                  </Badge>
                </div>
                
                <div>
                  <p className="text-sm font-medium mb-1">Priority</p>
                  <Badge className={getPriorityColor(selectedItem.priority)}>
                    {selectedItem.priority}
                  </Badge>
                </div>
                
                <div>
                  <p className="text-sm font-medium mb-1">Reported By</p>
                  <p>{selectedItem.reportedBy}</p>
                </div>
                
                <div>
                  <p className="text-sm font-medium mb-1">Reported At</p>
                  <p>{new Date(selectedItem.reportedAt).toLocaleString()}</p>
                </div>
                
                <div>
                  <p className="text-sm font-medium mb-1">Reason</p>
                  <p>{selectedItem.reason}</p>
                </div>
                
                <div>
                  <p className="text-sm font-medium mb-1">Description</p>
                  <p className="text-sm text-gray-600">{selectedItem.description}</p>
                </div>
                
                <div>
                  <p className="text-sm font-medium mb-1">Target Content</p>
                  <div className="p-3 bg-gray-50 rounded text-sm">
                    {selectedItem.targetData.content && (
                      <p className="mb-2">{selectedItem.targetData.content}</p>
                    )}
                    {selectedItem.targetData.userName && (
                      <p className="mb-1">Name: {selectedItem.targetData.userName}</p>
                    )}
                    {selectedItem.targetData.userEmail && (
                      <p className="mb-1">Email: {selectedItem.targetData.userEmail}</p>
                    )}
                    {selectedItem.targetData.imageUrl && (
                      <div className="mt-2">
                        <img 
                          src={selectedItem.targetData.imageUrl} 
                          alt="Reported content" 
                          className="w-full h-32 object-cover rounded"
                        />
                      </div>
                    )}
                  </div>
                </div>
                
                <div className="flex gap-2 pt-4">
                  {selectedItem.status === 'pending' && (
                    <>
                      <Button 
                        variant="success" 
                        size="sm" 
                        className="flex-1"
                        onClick={() => handleAction(selectedItem.id, 'approve')}
                      >
                        <Check className="w-4 h-4 mr-1" />
                        Approve
                      </Button>
                      <Button 
                        variant="danger" 
                        size="sm" 
                        className="flex-1"
                        onClick={() => handleAction(selectedItem.id, 'remove')}
                      >
                        <Trash2 className="w-4 h-4 mr-1" />
                        Remove
                      </Button>
                    </>
                  )}
                  <Button 
                    variant="outline" 
                    size="sm" 
                    className="flex-1"
                    onClick={() => handleAction(selectedItem.id, 'dismiss')}
                  >
                    <X className="w-4 h-4 mr-1" />
                    Dismiss
                  </Button>
                </div>
              </CardContent>
            </Card>
          ) : (
            <Card>
              <CardContent className="p-6 text-center text-gray-500">
                Select a report to view details
              </CardContent>
            </Card>
          )}
        </div>
      </div>
    </div>
  )
}
