import { useState } from 'react'
import * as XLSX from 'xlsx'

const emptyGroup = () => ({ persons: '', ipsPerPerson: '' })

export default function AllocatorPage() {
  const [cidr, setCidr] = useState('')
  const [groups, setGroups] = useState([emptyGroup()])
  const [result, setResult] = useState(null)
  const [error, setError] = useState('')
  const [cidrErr, setCidrErr] = useState('')
  const [loading, setLoading] = useState(false)

  const addGroup = () => setGroups(g => [...g, emptyGroup()])
  const removeGroup = i => setGroups(g => g.filter((_, idx) => idx !== i))
  const updateGroup = (i, field, val) =>
    setGroups(g => g.map((x, idx) => idx === i ? { ...x, [field]: val } : x))

  async function handleSubmit(e) {
    e.preventDefault()
    setError(''); setCidrErr(''); setResult(null)

    if (!cidr.trim()) { setCidrErr('CIDR is required'); return }

    const parsed = groups.map(g => ({
      persons: parseInt(g.persons, 10),
      ipsPerPerson: parseInt(g.ipsPerPerson, 10),
    }))

    setLoading(true)
    try {
      const res = await fetch('/api/allocate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ cidr: cidr.trim(), groups: parsed }),
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

  function downloadExcel() {
    const ws = XLSX.utils.json_to_sheet(result)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Allocations')
    XLSX.writeFile(wb, 'ip_allocations.xlsx')
  }

  return (
    <div>
      <h1>IP Group Allocator</h1>
      <p className="subtitle">Allocate contiguous IP ranges to groups within a CIDR block.</p>

      <div className="card">
        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: '1.25rem' }}>
            <label>Base CIDR (e.g. 192.168.1.0/24)</label>
            <input
              type="text"
              value={cidr}
              onChange={e => setCidr(e.target.value)}
              placeholder="192.168.1.0/24"
            />
            {cidrErr && <div className="inline-err">{cidrErr}</div>}
          </div>

          <h2>Groups</h2>
          {groups.map((g, i) => (
            <div key={i} className="group-card">
              <div>
                <label>Persons</label>
                <input
                  type="number"
                  min="1"
                  value={g.persons}
                  onChange={e => updateGroup(i, 'persons', e.target.value)}
                  placeholder="10"
                />
              </div>
              <div>
                <label>IPs per Person</label>
                <input
                  type="number"
                  min="1"
                  value={g.ipsPerPerson}
                  onChange={e => updateGroup(i, 'ipsPerPerson', e.target.value)}
                  placeholder="2"
                />
              </div>
              <button
                type="button"
                className="btn-danger"
                onClick={() => removeGroup(i)}
                disabled={groups.length === 1}
              >
                Remove
              </button>
            </div>
          ))}

          <div style={{ display: 'flex', gap: '0.75rem', marginTop: '0.5rem' }}>
            <button type="button" className="btn-secondary" onClick={addGroup}>+ Add Group</button>
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? 'Allocating…' : 'Allocate IPs'}
            </button>
          </div>

          {error && <div className="error-msg" style={{ marginTop: '0.75rem' }}>{error}</div>}
        </form>
      </div>

      {result && (
        <div className="card" style={{ marginTop: '1.5rem' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <h2 style={{ margin: 0 }}>Allocation Table ({result.length} records)</h2>
            <button className="btn-success" onClick={downloadExcel}>⬇ Download Excel</button>
          </div>
          <div style={{ overflowX: 'auto' }}>
            <table className="result-table">
              <thead>
                <tr>
                  <th>Group</th><th>Person ID</th><th>Start IP</th><th>End IP</th><th>Allocated IPs</th>
                </tr>
              </thead>
              <tbody>
                {result.map((row, i) => (
                  <tr key={i}>
                    <td>{row.Group}</td>
                    <td>{row.PersonID}</td>
                    <td>{row.StartIP}</td>
                    <td>{row.EndIP}</td>
                    <td>{row.AllocatedIPs}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
