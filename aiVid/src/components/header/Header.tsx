import { Tv } from 'lucide-react'
import { getAuth, signInWithPopup } from 'firebase/auth'
import Cookies from 'universal-cookie'
import { provider } from '../../config/firebaseConfig'
import { useNavigate } from 'react-router-dom'

export default function Header() {
    const cookies = new Cookies(null, { path: '/' })

    const navigate = useNavigate()

    const handleLogin = () => {
        signInWithPopup(getAuth(), provider)
            .then((result) => {
                const user = result.user
                cookies.set('uid', user.uid, { path: '/' })
                cookies.set('email', user.email, { path: '/' })
                cookies.set('name', user.displayName, { path: '/' })
                cookies.set('photo', user.photoURL, { path: '/' })
                navigate(`/${user.uid}/home`)
            })
    }
  return (
    <div className="w-full px-64 py-5 z-20 flex justify-between items-center">
        <div className='flex items-center justify-between gap-1'>
            <Tv className='w-6 h-6' strokeWidth={3} />
            <h1 className='text-xl font-extrabold mt-1'>MiniVid AI</h1>
        </div>

        <div className='flex items-center text-sm justify-between gap-1'>
            <button className='hover:cursor-pointer hover:opacity-60 px-4 py-2'>About</button>
            <button onClick={handleLogin} className='border hover:cursor-pointer hover:opacity-60 border-green-700 text-white px-4 py-2 rounded-3xl'>Get Started</button>
        </div>
    </div>
  )
}
