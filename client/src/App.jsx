import { BrowserRouter, Routes, Route, NavLink } from 'react-router-dom'
import HomePage from './pages/HomePage'
import AllocatorPage from './pages/AllocatorPage'
import SubnetPage from './pages/SubnetPage'
import HeaderPage from './pages/HeaderPage'
import './App.css'

function Nav() {
  const link = ({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')
  return (
    <nav className="navbar">
      <NavLink to="/" end className={link}>NetCal</NavLink>
      <div className="nav-links">
        <NavLink to="/allocator" className={link}>IP Allocator</NavLink>
        <NavLink to="/subnet" className={link}>Subnet Calc</NavLink>
        <NavLink to="/header" className={link}>Header Analyzer</NavLink>
      </div>
    </nav>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <Nav />
      <main className="main-content">
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/allocator" element={<AllocatorPage />} />
          <Route path="/subnet" element={<SubnetPage />} />
          <Route path="/header" element={<HeaderPage />} />
        </Routes>
      </main>
    </BrowserRouter>
  )
}
