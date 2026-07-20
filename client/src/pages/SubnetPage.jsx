import { useState } from 'react'

const FIELDS = [
  { key: 'network',      label: 'Network Address' },
  { key: 'broadcast',    label: 'Broadcast Address' },
  { key: 'subnetMask',   label: 'Subnet Mask' },
  { key: 'wildcardMask', label: 'Wildcard Mask' },
  { key: 'firstHost',    label: 'First Usable Host' },
  { key: 'lastHost',     label: 'Last Usable Host' },
  { key: 'usableHosts',  label: 'Total Usable Hosts' },
  { key: 'ipClass',      label: 'IP Class' },
  { key: 'isPrivate',    label: 'Private / Public', fmt: v => v ? 'Private' : 'Public' },
  { key: 'ipInt',        label: 'IP (Integer)' },
  { key: 'ipHex',        label: 'IP (Hex)' },
  { key: 'ipBinary',     label: 'IP (Binary)' },
  { key: 'maskBinary',   label: 'Mask (Binary)' },
]

export default function SubnetPage() {
  const [cidr, setCidr] = useState('')
  const [result, setResult] = useState(null)
  const [error, setError] = useState('')
  const [cidrErr, setCidrErr] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e) {
    e.preventDefault()
    setError(''); setCidrErr(''); setResult(null)

    if (!cidr.trim()) { setCidrErr('CIDR is required'); return }

    setLoading(true)
    try {
      const res = await fetch('/api/subnet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ cidr: cidr.trim() }),
      })
      const data = await res.json()
      if (!res.ok) { setError(data.error || 'Server error'); return }
      setResult(data)
    } catch {
      setError('Could not reach server')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div>
      <h1>Subnet Calculator</h1>
      <p className="subtitle">Enter an IPv4 CIDR to get full subnet details.</p>

      <div className="card">
        <form onSubmit={handleSubmit}>
          <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'flex-end' }}>
            <div style={{ flex: 1 }}>
              <label>CIDR Notation (e.g. 192.168.1.0/24)</label>
              <input
                type="text"
                value={cidr}
                onChange={e => setCidr(e.target.value)}
                placeholder="10.0.0.0/8"
              />
              {cidrErr && <div className="inline-err">{cidrErr}</div>}
            </div>
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? 'Calculating…' : 'Calculate'}
            </button>
          </div>
          {error && <div className="error-msg" style={{ marginTop: '0.75rem' }}>{error}</div>}
        </form>
      </div>

      {result && (
        <div className="card" style={{ marginTop: '1.5rem' }}>
          <h2>Results for {cidr}</h2>
          <div className="field-grid">
            {FIELDS.map(f => (
              <div key={f.key} className="field-item">
                <div className="field-label">{f.label}</div>
                <div className="field-value">
                  {f.fmt ? f.fmt(result[f.key]) : String(result[f.key])}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
