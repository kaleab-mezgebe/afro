// AFRO Admin Panel Design System
// Modern, clean, professional UI with orange primary color
// Fully responsive across mobile, tablet, laptop, and desktop

export const designSystem = {
  // 🎨 Colors
  colors: {
    primary: '#F97316', // Orange
    primaryHover: '#EA580C', // Darker orange
    background: '#F9FAFB', // Light background
    dark: '#111827', // Dark background for sidebar
    slate: '#334155', // Slate gray
    white: '#FFFFFF',
    border: '#E5E7EB',
    success: '#22C55E',
    warning: '#F59E0B',
    danger: '#EF4444',
    text: {
      primary: '#111827',
      secondary: '#6B7280',
      muted: '#9CA3AF',
      inverse: '#FFFFFF'
    }
  },

  // 📱 Responsive Breakpoints
  breakpoints: {
    mobile: '320px',
    mobileLarge: '480px',
    tablet: '768px',
    laptop: '1024px',
    desktop: '1280px',
    desktopLarge: '1536px'
  },

  // 📐 Responsive Spacing
  spacing: {
    xs: '4px',
    sm: '8px',
    md: '16px',
    lg: '24px',
    xl: '32px',
    xxl: '48px',
    // Responsive spacing
    responsive: {
      mobile: {
        xs: '2px',
        sm: '4px',
        md: '8px',
        lg: '12px',
        xl: '16px',
        xxl: '24px'
      },
      tablet: {
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '20px',
        xl: '24px',
        xxl: '32px'
      },
      desktop: {
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '32px',
        xxl: '48px'
      }
    }
  },

  // 🧩 Card Design (Responsive)
  card: {
    borderRadius: {
      mobile: '8px',
      tablet: '10px',
      desktop: '12px'
    },
    padding: {
      mobile: '12px',
      tablet: '16px',
      desktop: '20px'
    },
    background: '#FFFFFF',
    border: '1px solid #E5E7EB',
    shadow: '0 2px 8px rgba(0,0,0,0.05)',
    hoverShadow: '0 6px 20px rgba(0,0,0,0.08)',
    hoverTransform: 'translateY(-2px)',
    transition: 'all 0.2s ease-in-out'
  },

  // 🔘 Button Styles (Responsive)
  button: {
    primary: {
      background: '#F97316',
      color: '#FFFFFF',
      borderRadius: {
        mobile: '6px',
        desktop: '8px'
      },
      padding: {
        mobile: '8px 12px',
        desktop: '10px 16px'
      },
      fontSize: {
        mobile: '14px',
        desktop: '14px'
      },
      fontWeight: '500',
      border: 'none',
      cursor: 'pointer',
      transition: 'all 0.2s ease',
      hover: {
        background: '#EA580C',
        transform: 'translateY(-1px)'
      }
    },
    secondary: {
      background: 'transparent',
      border: '1px solid #E5E7EB',
      color: '#334155',
      borderRadius: {
        mobile: '6px',
        desktop: '8px'
      },
      padding: {
        mobile: '8px 12px',
        desktop: '10px 16px'
      },
      fontSize: {
        mobile: '14px',
        desktop: '14px'
      },
      fontWeight: '500',
      cursor: 'pointer',
      transition: 'all 0.2s ease',
      hover: {
        background: '#F9FAFB',
        borderColor: '#D1D5DB'
      }
    },
    danger: {
      background: '#EF4444',
      color: '#FFFFFF',
      borderRadius: {
        mobile: '6px',
        desktop: '8px'
      },
      padding: {
        mobile: '8px 12px',
        desktop: '10px 16px'
      },
      fontSize: {
        mobile: '14px',
        desktop: '14px'
      },
      fontWeight: '500',
      border: 'none',
      cursor: 'pointer',
      transition: 'all 0.2s ease',
      hover: {
        background: '#DC2626',
        transform: 'translateY(-1px)'
      }
    },
    success: {
      background: '#22C55E',
      color: '#FFFFFF',
      borderRadius: {
        mobile: '6px',
        desktop: '8px'
      },
      padding: {
        mobile: '8px 12px',
        desktop: '10px 16px'
      },
      fontSize: {
        mobile: '14px',
        desktop: '14px'
      },
      fontWeight: '500',
      border: 'none',
      cursor: 'pointer',
      transition: 'all 0.2s ease',
      hover: {
        background: '#16A34A',
        transform: 'translateY(-1px)'
      }
    }
  },

  // 🧭 Sidebar Design (Responsive)
  sidebar: {
    background: '#111827',
    text: '#9CA3AF',
    width: {
      mobile: '100%',
      desktop: '256px',
      collapsed: '64px'
    },
    active: {
      background: 'rgba(249,115,22,0.1)',
      color: '#F97316',
      borderLeft: '3px solid #F97316'
    },
    hover: {
      background: 'rgba(255,255,255,0.05)',
      color: '#FFFFFF'
    }
  },

  // ✨ Typography (Responsive)
  typography: {
    fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif",
    heading: {
      h1: {
        mobile: '24px',
        tablet: '28px',
        desktop: '32px'
      },
      h2: {
        mobile: '20px',
        tablet: '22px',
        desktop: '24px'
      },
      h3: {
        mobile: '18px',
        tablet: '19px',
        desktop: '20px'
      },
      h4: {
        mobile: '16px',
        tablet: '17px',
        desktop: '18px'
      },
      weight: '600'
    },
    body: {
      large: {
        mobile: '15px',
        desktop: '16px'
      },
      normal: {
        mobile: '13px',
        desktop: '14px'
      },
      small: {
        mobile: '11px',
        desktop: '12px'
      },
      weight: '400'
    },
    card: {
      number: {
        mobile: '24px',
        tablet: '26px',
        desktop: '28px'
      },
      label: {
        mobile: '12px',
        desktop: '14px'
      },
      numberWeight: '700',
      labelWeight: '500'
    }
  },

  // ⚡ Transitions
  transitions: {
    fast: '0.15s ease',
    normal: '0.2s ease',
    slow: '0.3s ease'
  },

  // 📊 Grid Systems (Responsive)
  grid: {
    stats: {
      mobile: 'grid-cols-1',
      tablet: 'grid-cols-2',
      laptop: 'grid-cols-3',
      desktop: 'grid-cols-4'
    },
    actions: {
      mobile: 'grid-cols-1',
      tablet: 'grid-cols-2',
      desktop: 'grid-cols-3'
    },
    tables: {
      mobile: 'grid-cols-1',
      tablet: 'grid-cols-1',
      desktop: 'grid-cols-1'
    }
  },

  // 🎯 Component Styles (Responsive)
  components: {
    // Stats Card
    statsCard: {
      display: 'flex',
      flexDirection: 'column',
      gap: {
        mobile: '6px',
        desktop: '8px'
      },
      padding: {
        mobile: '12px',
        tablet: '16px',
        desktop: '20px'
      },
      borderRadius: {
        mobile: '8px',
        desktop: '12px'
      },
      background: '#FFFFFF',
      border: '1px solid #E5E7EB',
      boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
      transition: 'all 0.2s ease'
    },

    // Table
    table: {
      header: {
        background: '#F9FAFB',
        borderBottom: '1px solid #E5E7EB',
        fontSize: {
          mobile: '11px',
          desktop: '12px'
        },
        fontWeight: '600',
        color: '#6B7280',
        textTransform: 'uppercase',
        letterSpacing: '0.05em',
        padding: {
          mobile: '8px 12px',
          desktop: '12px 16px'
        }
      },
      row: {
        borderBottom: '1px solid #F3F4F6',
        hover: {
          background: '#F9FAFB'
        },
        padding: {
          mobile: '8px 12px',
          desktop: '12px 16px'
        }
      },
      cell: {
        fontSize: {
          mobile: '12px',
          desktop: '14px'
        },
        padding: {
          mobile: '8px 12px',
          desktop: '12px 16px'
        }
      }
    },

    // Modal
    modal: {
      overlay: {
        background: 'rgba(0, 0, 0, 0.5)',
        backdropFilter: 'blur(4px)'
      },
      content: {
        background: '#FFFFFF',
        borderRadius: {
          mobile: '12px',
          desktop: '16px'
        },
        padding: {
          mobile: '16px',
          tablet: '24px',
          desktop: '32px'
        },
        boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)',
        border: '1px solid #E5E7EB',
        maxWidth: {
          mobile: '95vw',
          tablet: '90vw',
          desktop: '80vw'
        },
        width: {
          mobile: '100%',
          desktop: '600px'
        }
      }
    },

    // Form
    form: {
      input: {
        borderRadius: {
          mobile: '6px',
          desktop: '8px'
        },
        border: '1px solid #D1D5DB',
        padding: {
          mobile: '8px 10px',
          desktop: '10px 12px'
        },
        fontSize: {
          mobile: '14px',
          desktop: '14px'
        },
        transition: 'all 0.2s ease',
        focus: {
          borderColor: '#F97316',
          boxShadow: '0 0 0 3px rgba(249,115,22,0.1)'
        }
      },
      label: {
        fontSize: {
          mobile: '13px',
          desktop: '14px'
        },
        fontWeight: '500',
        color: '#374151',
        marginBottom: {
          mobile: '4px',
          desktop: '6px'
        }
      }
    }
  }
};

// CSS Classes for Tailwind-like usage
export const cn = (...classes: string[]) => {
  return classes.filter(Boolean).join(' ');
};

// 📱 Responsive Utility Functions
export const responsive = {
  // Generate responsive class names
  className: (mobile: string, tablet?: string, desktop?: string) => {
    const classes = [mobile];
    if (tablet) classes.push(`md:${tablet}`);
    if (desktop) classes.push(`lg:${desktop}`);
    return classes.join(' ');
  },

  // Responsive spacing
  spacing: (size: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'xxl') => {
    return responsive.className(
      `p-${size}`,
      `md:p-${size}`,
      `lg:p-${size}`
    );
  },

  // Responsive grid
  grid: (mobile: string, tablet?: string, desktop?: string) => {
    return responsive.className(mobile, tablet, desktop);
  },

  // Responsive text sizes
  text: (mobile: string, tablet?: string, desktop?: string) => {
    return responsive.className(mobile, tablet, desktop);
  },

  // Responsive display
  display: (mobile: string, tablet?: string, desktop?: string) => {
    return responsive.className(mobile, tablet, desktop);
  }
};

// 🎯 Helper functions for responsive styling
export const getResponsiveValue = (
  mobile: string,
  tablet?: string,
  desktop?: string
) => {
  return { mobile, tablet, desktop };
};

// 📐 Responsive breakpoints for media queries
export const breakpoints = {
  mobile: '(max-width: 767px)',
  tablet: '(min-width: 768px) and (max-width: 1023px)',
  laptop: '(min-width: 1024px) and (max-width: 1279px)',
  desktop: '(min-width: 1280px)'
};

// 🎨 Responsive color utilities
export const responsiveColors = {
  background: responsive.className('bg-gray-50', 'bg-gray-50', 'bg-gray-50'),
  card: responsive.className('bg-white', 'bg-white', 'bg-white'),
  text: responsive.className('text-gray-900', 'text-gray-900', 'text-gray-900'),
  muted: responsive.className('text-gray-600', 'text-gray-600', 'text-gray-600')
};

// 📊 Responsive grid templates
export const responsiveGrids = {
  stats: responsive.className('grid-cols-1', 'grid-cols-2', 'grid-cols-4'),
  actions: responsive.className('grid-cols-1', 'grid-cols-2', 'grid-cols-3'),
  forms: responsive.className('grid-cols-1', 'grid-cols-2', 'grid-cols-2'),
  tables: responsive.className('grid-cols-1', 'grid-cols-1', 'grid-cols-1')
};

// Helper functions for styling
export const getButtonStyles = (variant: 'primary' | 'secondary' | 'danger' | 'success' = 'primary') => {
  const base = 'inline-flex items-center justify-center font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2';

  switch (variant) {
    case 'primary':
      return cn(base, 'bg-orange-500 text-white hover:bg-orange-600 focus:ring-orange-500');
    case 'secondary':
      return cn(base, 'bg-transparent border border-gray-300 text-gray-700 hover:bg-gray-50 focus:ring-orange-500');
    case 'danger':
      return cn(base, 'bg-red-500 text-white hover:bg-red-600 focus:ring-red-500');
    case 'success':
      return cn(base, 'bg-green-500 text-white hover:bg-green-600 focus:ring-green-500');
    default:
      return base;
  }
};

export const getCardStyles = (hoverable = true) => {
  const base = 'bg-white border border-gray-200 rounded-xl p-5 shadow-sm';
  return hoverable ? cn(base, 'hover:shadow-md hover:-translate-y-1 transition-all duration-200') : base;
};

export const getSidebarItemStyles = (active = false) => {
  const base = 'flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-all duration-200';
  if (active) {
    return cn(base, 'bg-orange-50 text-orange-600 border-l-3 border-orange-500');
  }
  return cn(base, 'text-gray-600 hover:bg-gray-800 hover:text-white');
};
