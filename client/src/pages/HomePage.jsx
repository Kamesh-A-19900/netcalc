import { Link } from 'react-router-dom'

const tools = [
  {
    to: '/allocator',
    icon: '🗂️',
    title: 'IP Group Allocator',
    desc: 'Assign contiguous IP ranges to groups of people within a CIDR block.',
  },
  {
    to: '/subnet',
    icon: '🌐',
    title: 'Subnet Calculator',
    desc: 'Get network address, broadcast, usable hosts, mask, and IP class from any CIDR.',
  },
  {
    to: '/header',
    icon: '🔍',
    title: 'TCP/UDP Header Analyzer',
    desc: 'Decode raw TCP or UDP packet headers from a hex string.',
  },
]

export default function HomePage() {
  return (
    <div>
      <h1>NetCal</h1>
      <p className="subtitle">Networking utilities — IP allocation, subnet math, and header decoding.</p>
      <div className="home-grid">
        {tools.map(t => (
          <Link key={t.to} to={t.to} className="home-card">
            <div className="home-card-icon">{t.icon}</div>
            <h3>{t.title}</h3>
            <p>{t.desc}</p>
          </Link>
        ))}
      </div>
    </div>
  )
}
