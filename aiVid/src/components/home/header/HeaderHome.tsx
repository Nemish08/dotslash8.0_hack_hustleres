import { CircleUser, GalleryHorizontalEnd, LogOut, Menu, Tv } from "lucide-react"
import { useState } from "react"
import Cookies from "universal-cookie"
// import { getHistory } from "../../../utils/getHistory"
import { useNavigate } from "react-router-dom"

export default function HeaderHome() {
    const cookies = new Cookies(null, { path: '/' })
    const [openMenu, setOpenMenu] = useState(false)
    const navigate = useNavigate()

    const handleGetHistory = () => {
        navigate(`/${cookies.get('uid')}/history`)
    }

    return (
        <div className="w-full z-30 py-5 flex justify-between items-center">
            <div className='flex items-center justify-between gap-1'>
                <Tv className='w-6 h-6' strokeWidth={3} />
                <h1 className='text-xl font-extrabold mt-1'>MiniVid AI</h1>
            </div>

            <div className='flex items-center text-sm justify-between gap-5 relative'>
                <div className="flex border border-gray-800 p-2 rounded-3xl items-center justify-between gap-1">
                    <img src={cookies.get('photo')} alt="pfp" className="w-5 h-5 rounded-full object-cover" />
                    <p className="text-xs font-medium">{cookies.get('name')}</p>
                </div>
                <button title="Menu" className="hover:cursor-pointer hover:opacity-60" onClick={() => setOpenMenu(!openMenu)}><Menu className='w-5 h-5' strokeWidth={3} /></button>

                {
                    openMenu && (
                        <div className="absolute shadow-2xl top-12 w-52 z-10 right-0  bg-[#131313] border border-gray-800 p-2 rounded-lg flex flex-col items-start justify-start gap-1">
                            <div onClick={handleGetHistory} className="flex items-center justify-start gap-1">
                                <button title="View History" className="hover:cursor-pointer hover:opacity-60 flex items-center justify-start gap-1"><GalleryHorizontalEnd className='w-4 h-4' />History</button>
                            </div>

                            <div className="flex w-full items-start justify-start gap-1 flex-col border-t border-gray-800 mt-2 pt-2">
                                <p className="flex items-center justify-start gap-1"><CircleUser className='w-4 h-4'/>Account</p>
                                <p className="text-xs text-gray-300">{cookies.get('email')}</p>
                            </div>

                            <div className="flex w-full items-center justify-start gap-1 border-t border-gray-800 mt-2 pt-2">
                                <button className="hover:cursor-pointer hover:opacity-60 bg-red-600 w-full text-white font-semibold p-2 rounded-lg flex items-center justify-start gap-1"><LogOut className='w-4 h-4' strokeWidth={3} />Logout</button>
                            </div>
                        </div>
                    )
                }
            </div>
        </div>
  )
}
