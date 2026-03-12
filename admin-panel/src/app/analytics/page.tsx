'use client'

import { useEffect, useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Badge } from '@/components/ui/Badge'
import { TrendingUp, TrendingDown, Users, DollarSign, Calendar, Download, Filter, BarChart3, PieChart, Activity } from 'lucide-react'
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'

interface AnalyticsData {
  overview: {
    totalUsers: number
    totalProviders: number
    totalBookings: number
    totalRevenue: number
    userGrowth: number
    revenueGrowth: number
    bookingGrowth: number
  }
  chartData: {
    daily: Array<{ date: string; bookings: number; revenue: number; users: number }>
    monthly: Array<{ month: string; bookings: number; revenue: number; users: number }>
  }
  topServices: Array<{ name: string; bookings: number; revenue: number; rating: number }>
  topProviders: Array<{ name: string; bookings: number; revenue: number; rating: number }>
  demographics: {
    ageGroups: Array<{ range: string; count: number; percentage: number }>
    locations: Array<{ city: string; count: number; percentage: number }>
    devices: Array<{ device: string; count: number; percentage: number }>
  }
}

export default function AnalyticsPage() {
  const [timeRange, setTimeRange] = useState<'7d' | '30d' | '90d' | '1y'>('30d')
  const [analyticsData, setAnalyticsData] = useState<AnalyticsData | null>(null)
  const [activeChart, setActiveChart] = useState<'bookings' | 'revenue' | 'users'>('bookings')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Mock data - replace with actual API call
    setTimeout(() => {
      setAnalyticsData({
        overview: {
          totalUsers: 15420,
          totalProviders: 342,
          totalBookings: 8934,
          totalRevenue: 234567.89,
          userGrowth: 12.5,
          revenueGrowth: 18.3,
          bookingGrowth: 15.7
        },
        chartData: {
          daily: [
            { date: '2024-01-01', bookings: 45, revenue: 2340, users: 12 },
            { date: '2024-01-02', bookings: 52, revenue: 2680, users: 15 },
            { date: '2024-01-03', bookings: 38, revenue: 1950, users: 8 },
            { date: '2024-01-04', bookings: 61, revenue: 3150, users: 18 },
            { date: '2024-01-05', bookings: 55, revenue: 2840, users: 14 },
            { date: '2024-01-06', bookings: 48, revenue: 2480, users: 11 },
            { date: '2024-01-07', bookings: 67, revenue: 3460, users: 20 }
          ],
          monthly: [
            { month: 'Jan', bookings: 2340, revenue: 120000, users: 450 },
            { month: 'Feb', bookings: 2456, revenue: 128000, users: 480 },
            { month: 'Mar', bookings: 2678, revenue: 142000, users: 520 },
            { month: 'Apr', bookings: 2890, revenue: 156000, users: 580 },
            { month: 'May', bookings: 3123, revenue: 168000, users: 620 },
            { month: 'Jun', bookings: 3345, revenue: 182000, users: 680 }
          ]
        },
        topServices: [
          { name: 'Haircut & Styling', bookings: 1234, revenue: 45670, rating: 4.8 },
          { name: 'Manicure & Pedicure', bookings: 987, revenue: 34230, rating: 4.7 },
          { name: 'Facial Treatment', bookings: 756, revenue: 28940, rating: 4.9 },
          { name: 'Massage Therapy', bookings: 623, revenue: 31200, rating: 4.6 },
          { name: 'Beard Trim', bookings: 543, revenue: 15430, rating: 4.5 }
        ],
        topProviders: [
          { name: 'Michael Brown', bookings: 234, revenue: 12340, rating: 4.9 },
          { name: 'Lisa Anderson', bookings: 198, revenue: 10560, rating: 4.8 },
          { name: 'Sarah Johnson', bookings: 176, revenue: 9230, rating: 4.7 },
          { name: 'James Wilson', bookings: 154, revenue: 8450, rating: 4.8 },
          { name: 'Emma Davis', bookings: 143, revenue: 7230, rating: 4.6 }
        ],
        demographics: {
          ageGroups: [
            { range: '18-24', count: 2340, percentage: 15.2 },
            { range: '25-34', count: 5432, percentage: 35.2 },
            { range: '35-44', count: 4123, percentage: 26.7 },
            { range: '45-54', count: 2345, percentage: 15.2 },
            { range: '55+', count: 1180, percentage: 7.7 }
          ],
          locations: [
            { city: 'New York', count: 3421, percentage: 22.2 },
            { city: 'Los Angeles', count: 2876, percentage: 18.7 },
            { city: 'Chicago', count: 1987, percentage: 12.9 },
            { city: 'Houston', count: 1654, percentage: 10.7 },
            { city: 'Phoenix', count: 1234, percentage: 8.0 }
          ],
          devices: [
            { device: 'Mobile', count: 12340, percentage: 80.0 },
            { device: 'Desktop', count: 2340, percentage: 15.2 },
            { device: 'Tablet', count: 740, percentage: 4.8 }
          ]
        }
      })
      setLoading(false)
    }, 1000)
  }, [])

  if (loading) {
    return (
      <div className="p-6">
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900"></div>
        </div>
      </div>
    )
  }

  if (!analyticsData) {
    return <div className="p-6">Failed to load analytics data</div>
  }

  const chartData = timeRange === '7d' ? analyticsData.chartData.daily : analyticsData.chartData.monthly

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Analytics Dashboard</h1>
        <div className="flex gap-2">
          <div className="flex bg-gray-100 rounded-lg p-1">
            {[
              { value: '7d', label: '7 Days' },
              { value: '30d', label: '30 Days' },
              { value: '90d', label: '90 Days' },
              { value: '1y', label: '1 Year' }
            ].map((range) => (
              <Button
                key={range.value}
                variant={timeRange === range.value ? 'primary' : 'outline'}
                size="sm"
                onClick={() => setTimeRange(range.value as any)}
              >
                {range.label}
              </Button>
            ))}
          </div>
          <Button variant="outline" className="flex items-center gap-2">
            <Download className="w-4 h-4" />
            Export
          </Button>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              <Users className="w-4 h-4" />
              Total Users
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{analyticsData.overview.totalUsers.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground flex items-center gap-1">
              <TrendingUp className="w-3 h-3" />
              +{analyticsData.overview.userGrowth}% from last period
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              <Users className="w-4 h-4" />
              Total Providers
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{analyticsData.overview.totalProviders.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground">Active service providers</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              <Calendar className="w-4 h-4" />
              Total Bookings
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{analyticsData.overview.totalBookings.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground flex items-center gap-1">
              <TrendingUp className="w-3 h-3" />
              +{analyticsData.overview.bookingGrowth}% from last period
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              <DollarSign className="w-4 h-4" />
              Total Revenue
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">${analyticsData.overview.totalRevenue.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground flex items-center gap-1">
              <TrendingUp className="w-3 h-3" />
              +{analyticsData.overview.revenueGrowth}% from last period
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        <Card className="lg:col-span-2">
          <CardHeader>
            <div className="flex justify-between items-center">
              <CardTitle className="flex items-center gap-2">
                <BarChart3 className="w-5 h-5" />
                Performance Trends
              </CardTitle>
              <div className="flex gap-2">
                {[
                  { value: 'bookings', label: 'Bookings' },
                  { value: 'revenue', label: 'Revenue' },
                  { value: 'users', label: 'Users' }
                ].map((chart) => (
                  <Button
                    key={chart.value}
                    variant={activeChart === chart.value ? 'primary' : 'outline'}
                    size="sm"
                    onClick={() => setActiveChart(chart.value as any)}
                  >
                    {chart.label}
                  </Button>
                ))}
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey={timeRange === '7d' ? 'date' : 'month'} />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line
                  type="monotone"
                  dataKey={activeChart}
                  stroke="#8884d8"
                  strokeWidth={2}
                  name={activeChart.charAt(0).toUpperCase() + activeChart.slice(1)}
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <PieChart className="w-5 h-5" />
              Device Distribution
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {analyticsData.demographics.devices.map((device) => (
                <div key={device.device} className="flex justify-between items-center">
                  <span className="text-sm font-medium">{device.device}</span>
                  <div className="flex items-center gap-2">
                    <div className="w-24 bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-blue-600 h-2 rounded-full"
                        style={{ width: `${device.percentage}%` }}
                      />
                    </div>
                    <span className="text-sm text-gray-600">{device.percentage}%</span>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Top Services and Providers */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <Card>
          <CardHeader>
            <CardTitle>Top Services</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {analyticsData.topServices.map((service, index) => (
                <div key={service.name} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center text-sm font-medium">
                      {index + 1}
                    </div>
                    <div>
                      <p className="font-medium">{service.name}</p>
                      <p className="text-sm text-gray-500">{service.bookings} bookings</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-medium">${service.revenue.toLocaleString()}</p>
                    <div className="flex items-center gap-1">
                      <span className="text-sm text-gray-500">★</span>
                      <span className="text-sm">{service.rating}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Top Providers</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {analyticsData.topProviders.map((provider, index) => (
                <div key={provider.name} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center text-sm font-medium">
                      {index + 1}
                    </div>
                    <div>
                      <p className="font-medium">{provider.name}</p>
                      <p className="text-sm text-gray-500">{provider.bookings} bookings</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-medium">${provider.revenue.toLocaleString()}</p>
                    <div className="flex items-center gap-1">
                      <span className="text-sm text-gray-500">★</span>
                      <span className="text-sm">{provider.rating}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Demographics */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Age Distribution</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {analyticsData.demographics.ageGroups.map((age) => (
                <div key={age.range} className="flex justify-between items-center">
                  <span className="text-sm font-medium">{age.range}</span>
                  <div className="flex items-center gap-2">
                    <div className="w-20 bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-green-600 h-2 rounded-full"
                        style={{ width: `${age.percentage}%` }}
                      />
                    </div>
                    <span className="text-sm text-gray-600">{age.percentage}%</span>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Top Locations</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {analyticsData.demographics.locations.map((location) => (
                <div key={location.city} className="flex justify-between items-center">
                  <span className="text-sm font-medium">{location.city}</span>
                  <div className="flex items-center gap-2">
                    <div className="w-20 bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-purple-600 h-2 rounded-full"
                        style={{ width: `${location.percentage}%` }}
                      />
                    </div>
                    <span className="text-sm text-gray-600">{location.percentage}%</span>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Activity className="w-5 h-5" />
              Quick Stats
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Avg. Booking Value</span>
                <span className="font-medium">$26.25</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Conversion Rate</span>
                <span className="font-medium">12.3%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Customer Retention</span>
                <span className="font-medium">78.5%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Avg. Rating</span>
                <span className="font-medium">4.7★</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
