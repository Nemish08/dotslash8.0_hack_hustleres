import { ArrowUpRight, AudioLines, RectangleHorizontal, RectangleVertical, Square } from "lucide-react"
import Header from "../header/Header"
import { getAuth, signInWithPopup } from 'firebase/auth'
import Cookies from 'universal-cookie'
import { provider } from '../../config/firebaseConfig'
import { useNavigate } from 'react-router-dom'

export default function LandingPage() {
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
        <div className="w-full h-full relative flex flex-col justify-start items-center">
            <Header />

            <div className="fixed w-full h-full inset-0 overflow-hidden z-10">
                <div className='w-full h-full relative'>
                    <div className="absolute -top-36 -left-40 w-96 h-60 bg-emerald-800/80 rounded-full  mix-blend-multiply filter blur-3xl"></div>
                    <div className="absolute top-0 -right-40 w-96 h-96 bg-green-900/30 rounded-full mix-blend-multiply filter blur-3xl"></div>
                    {/* <div className="absolute -bottom-40 left-20 w-96 h-96 bg-teal-900/30 rounded-full mix-blend-multiply filter blur-3xl">THIHISHSIH</div> */}
                </div>
            </div>
            
            <div className="w-[60%] flex flex-col z-20 items-center justify-start gap-2 relative mt-2">
                <img src="/assets/landing.jpg" alt="landing" className="rounded-xl shadow-md brightness-40 h-full w-full object-cover" />
                {/* <video src="/assets/landing5.mp4" autoPlay muted={mute} loop className="rounded-lg brightness-40 w-[80%] object-cover"></video> */}
                <div className="absolute bottom-1 -left-9 flex flex-col items-start gap-1 justify-center">
                    <h3 className="font-semibold text-5xl text-gray-300">Welcome to</h3>
                    <h2 className="font-extrabold text-8xl mt-1 leading-16">MiniVid AI</h2>
                </div>

                <div className="absolute top-1 text-gray-200 -right-9 flex flex-col items-start gap-1 justify-center">
                    <p className="max-w-64 text-right text-sm">Empowering creators to craft stunning short-form videos with AI-driven scripts, speech, and visuals.</p>
                </div>

                <button onClick={handleLogin} className="hover:cursor-pointer hover:opacity-60 absolute bottom-1 font-bold text-2xl flex items-center -right-7">Get started <ArrowUpRight className="w-7 h-7" strokeWidth={3} /></button>
            </div>

            <div className="w-[65%] mt-44 flex flex-col items-start justify-start gap-2">
                <h2 className="font-bold text-center text-5xl">Steps to generate a video</h2>

                <div className="w-full grid grid-cols-2 gap-4 items-start justify-center p-3 border border-gray-800 bg-[#111111] rounded-xl mt-3">
                    <div className="rounded-lg mt-10 w-[85%] flex flex-col items-center justify-center p-4">
                        <p className="font-medium text-gray-200">1.&nbsp;Input prompt, <span className="text-green-600">for eg.,</span></p>
                        <div className="flex mt-5 text-sm items-start justify-start gap-2 flex-col">
                            <p className="p-3 border border-green-900 rounded-3xl">"content about dog"</p>
                            <p className="p-3 border border-green-900 rounded-3xl">"artificial intelligence and it's consequences"</p>
                            <p className="p-3 border border-green-900 rounded-3xl">"animals and their environment"</p>
                        </div>
                    </div>

                    <div className="rounded-lg mt-12 w-[85%] flex flex-col items-center justify-center p-4">
                        <p className="font-medium text-gray-200">2.&nbsp;Select orientation</p>
                        <div className="flex mt-5 items-center justify-center gap-6">
                            <div className="flex items-center p-6 rounded-lg bg-[#1a1a1a] justify-center gap-2 flex-col">
                                <RectangleHorizontal className="text-green-600 w-6 h-6" />
                                <p className=" text-gray-200">Horizontal</p>
                            </div>
                            <div className="flex items-center p-6 rounded-lg bg-[#1a1a1a] justify-center gap-2 flex-col">
                                <RectangleVertical className="text-green-600 w-6 h-6" />
                                <p className=" text-gray-200">Vertical</p>
                            </div>
                            <div className="flex items-center p-6 rounded-lg bg-[#1a1a1a] justify-center gap-2 flex-col">
                                <Square className="text-green-600 w-6 h-6" />
                                <p className=" text-gray-200">Square</p>
                            </div>
                        </div>
                    </div>  

                    <div className="rounded-lg mt-10 w-[85%] flex flex-col items-center justify-center p-4">
                        <p className="font-medium text-gray-200">3.&nbsp;Select voice</p>

                        <div className="flex mt-5 justify-center gap-4 items-center">
                            <p className="flex flex-col items-center justify-center gap-3 w-24 h-24 rounded-lg bg-[#1a1a1a] text-sm"><AudioLines className="text-blue-800 w-6 h-6" />Male</p>
                            <p className="flex flex-col items-center justify-center gap-3 w-24 h-24 rounded-lg bg-[#1a1a1a] text-sm"><AudioLines className="text-pink-800 w-6 h-6" />Female</p>
                        </div>
                    </div>

                    <div className="rounded-lg mt-10 w-[85%] flex flex-col items-center justify-center p-4">
                        <p className="font-medium text-gray-200">4.&nbsp;Select subtitles style</p>
                        <p className="font-semibold p-2 text-sm text-gray-400 mt-3">This is the subtitle style. You can change it.</p>
                        <p className="italic bg-gray-500/40 text-yellow-300 p-2 text-sm mt-3">This is the subtitle style. You can change it.</p>

                    </div>

                    <div className="rounded-lg col-span-2 w-full mt-12 flex flex-col items-center justify-center p-4">
                        <p className="font-medium text-gray-200">5.&nbsp;Generate</p>
                        <p className="p-3 rounded-3xl border border-green-600 text-sm bg-[#03570048] mt-3 text-white font-semibold">Generate video</p>
                    </div>     
                </div>     
            </div>

            <div className="w-[65%] flex flex-col items-start justify-start gap-2 relative mt-44">
                <p className="font-bold text-5xl">Technologies used</p>

                <div className="w-full grid grid-cols-4 gap-10 items-center justify-between mt-5">
                    {/* <svg xmlns="http://www.w3.org/2000/svg" width="153" height="102" viewBox="0 0 30 10" fill="none">
                        <path d="M8.31809 1.16929L10.2823 0L15.2252 7.34819L13.4598 8.40706V10.8561H13.1065L8.31809 3.72872V1.16929Z" fill="white"/>
                        <path d="M4.148 3.35445L6.11217 2.18516L11.0551 9.53335L9.28971 10.5922V13.0412H8.93639L4.148 5.91388V3.35445Z" fill="white"/>
                        <path d="M0 5.53845L1.96417 4.36916L6.90714 11.7173L5.14171 12.7762V15.2252H4.78839L0 8.09788V5.53845Z" fill="white"/>
                    </svg> */}
                    <img src="https://cdn4.iconfinder.com/data/icons/logos-3/600/React.js_logo-512.png" alt="react" className="mt-4 w-20 object-cover h-auto" />
                    <img src="https://cdn-icons-png.flaticon.com/512/5968/5968381.png" alt="typescript" className="mt-4 w-20 object-cover h-auto" />
                    <img src="https://static-00.iconduck.com/assets.00/tailwind-css-icon-1024x615-fdeis5r1.png" alt="tailwind" className="mt-4 w-20 object-cover h-auto" />
                    <img src="https://cdn.iconscout.com/icon/free/png-256/free-node-js-logo-icon-download-in-svg-png-gif-file-formats--nodejs-programming-language-pack-logos-icons-1174925.png?f=webp&w=256" alt="nodejs" className="mt-4 w-20 object-cover h-auto" />
                    <img src="https://www.kindpng.com/picc/m/188-1882416_flask-python-logo-hd-png-download.png" alt="flask" className="mt-4 w-24 object-cover h-auto rounded-md" />
                    <div className="bg-white w-24 mt-4 flex items-center justify-center rounded-md">
                        <img src="https://www.unixmen.com/wp-content/uploads/2014/04/ffmpeg-logo.png" alt="ffmpeg" className="py-3 rounded-md w-full object-cover h-auto" />
                    </div>
                    <img src="https://asset.brandfetch.io/idxygbEPCQ/idzCyF-I44.png?updated=1668515712972" alt="groq" className="mt-4 w-24 object-cover h-auto rounded-md"   />
                    <img src="https://cdn.iconscout.com/icon/free/png-256/free-flutter-logo-icon-download-in-svg-png-gif-file-formats--technology-social-media-vol-3-pack-logos-icons-2944876.png?f=webp&w=256" alt="flutter" className="mt-4 w-20 object-cover h-auto rounded-md" />
                    <img src="https://toppng.com/uploads/preview/dart-logo-11609359002t083vzxxh2.png" alt="dart" className="mt-4 w-20 object-cover h-auto rounded-md" />
                    <img src="https://firebase.google.com/static/images/brand-guidelines/logo-logomark.png" alt="firebase" className="mt-4 w-22 object-cover h-auto rounded-md" />
                </div>
            </div>
        </div>
    )
}
