import { useState } from 'react'

const UDP_FIELDS = [
  { key: 'protocol',          label: 'Protocol' },
  { key: 'totalBytes',        label: 'Total Bytes (from Length field)' },
  { key: 'srcPort',           label: 'Source Port' },
  { key: 'dstPort',           label: 'Destination Port' },
  { key: 'length',            label: 'Length (header + payload)' },
  { key: 'rawChecksum',       label: 'Checksum (from header)' },
  { key: 'computedChecksum',  label: 'Checksum (computed)' },
]

const TCP_FIELDS = [
  { key: 'protocol',          label: 'Protocol' },
  { key: 'totalBytes',        label: 'Header Length (bytes)' },
  { key: 'srcPort',           label: 'Source Port' },
  { key: 'dstPort',           label: 'Destination Port' },
  { key: 'seqNumber',         label: 'Sequence Number' },
  { key: 'ackNumber',         label: 'Acknowledgment Number' },
  { key: 'headerLength',      label: 'Data Offset → Header Length' },
  { key: 'flags',             label: 'Flags (hex)' },
  { key: 'flagsDecoded',      label: 'Flags (decoded)' },
  { key: 'window',            label: 'Window Size' },
  { key: 'rawChecksum',       label: 'Checksum (from header)' },
  { key: 'computedChecksum',  label: 'Checksum (computed over header bytes)' },
  { key: 'urgentPtr',         label: 'Urgent Pointer' },
]

export default function HeaderPage() {
  const [header, setHeader] = useState('')
  const [result, setResult] = useState(null)
  const [error, setError] = useState('')
  const [headerErr, setHeaderErr] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e) {
    e.preventDefault()
    setError(''); setHeaderErr(''); setResult(null)

    const trimmed = header.trim()
    if (trimmed.length < 16) {
      setHeaderErr('Header must be at least 16 hex characters (8 bytes for UDP)')
      return
    }

    setLoading(true)
    try {
      const res = await fetch('/api/header', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ header: trimmed }),
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

  const fields = result?.protocol === 'TCP' ? TCP_FIELDS : UDP_FIELDS

  return (
    <div>
      <h1>TCP/UDP Header Analyzer</h1>
      <p className="subtitle">
        Paste a raw packet header as hex. 16 hex chars (8 bytes) = UDP &nbsp;|&nbsp; 40+ hex chars (20+ bytes) = TCP
      </p>

      <div className="card">
        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: '0.75rem' }}>
            <label>Hex Header String</label>
            <input
              type="text"
              value={header}
              onChange={e => setHeader(e.target.value)}
              placeholder="0050006e001c0000  (UDP)  or  30390050000003E80000007850021A2B0000000000000000…  (TCP)"
              style={{ fontFamily: 'monospace' }}
            />
            {headerErr && <div className="inline-err">{headerErr}</div>}
          </div>
          <div style={{ display: 'flex', gap: '0.75rem' }}>
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? 'Analyzing…' : 'Analyze Header'}
            </button>
            <button
              type="button"
              className="btn-secondary"
              onClick={() => { setHeader(''); setResult(null); setError(''); setHeaderErr('') }}
            >
              Clear
            </button>
          </div>
          {error && <div className="error-msg" style={{ marginTop: '0.75rem' }}>{error}</div>}
        </form>
      </div>

      {result && (
        <div className="card" style={{ marginTop: '1.5rem' }}>
          <h2>
            {result.protocol} Header — {result.totalBytes} bytes
          </h2>
          <div className="field-grid">
            {fields.map(f => (
              <div key={f.key} className="field-item">
                <div className="field-label">{f.label}</div>
                <div className="field-value">{String(result[f.key])}</div>
              </div>
            ))}
          </div>
          {result.checksumNote && (
            <p style={{ marginTop: '1rem', fontSize: '0.8rem', color: '#64748b' }}>
              ⚠ {result.checksumNote}
            </p>
          )}
        </div>
      )}
    </div>
  )
}
