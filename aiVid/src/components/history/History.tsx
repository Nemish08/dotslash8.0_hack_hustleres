import { ChevronLeft, HistoryIcon } from "lucide-react"
import HeaderHome from "../home/header/HeaderHome"
import { useNavigate } from "react-router-dom"
import { useEffect, useState } from "react"
import { getHistory } from "../../utils/getHistory"

interface Response {
    url: string
    _id: string
    prompt: string
    timestamp: string
    __v: number
}

export default function History() {
    const navigate = useNavigate()
    const [history, setHistory] = useState<Response[]>([])

    function timeAgo(isoString: string): string {
        const now = new Date();
        const past = new Date(isoString);
        const diffInSeconds = Math.floor((now.getTime() - past.getTime()) / 1000);
    
        if (diffInSeconds < 60) return `${diffInSeconds} sec ago`;
        if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)} min ago`;
        if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)} h ago`;
    
        const diffInDays = Math.floor(diffInSeconds / 86400);
        if (diffInDays === 1) return "Yesterday";
        if (diffInDays < 7) return past.toLocaleDateString("en-US", { weekday: "long" });
    
        const options: Intl.DateTimeFormatOptions = { day: "numeric", month: "long", year: "numeric" };
        return past.toLocaleDateString("en-US", options);
    }
    

    useEffect(() => {
        const callFunc = async () => {
            // @ts-ignore
            const response: Response[] | undefined = await getHistory()
            console.log(response)

            if (response)
                setHistory(response)
        }

        callFunc()
    }, [])

    return (
        <div className="w-[60%] relative h-full flex flex-col items-center justify-start">
            <HeaderHome />

            <div className="fixed w-full h-full inset-0 overflow-hidden z-10">
                <div className='w-full h-full relative'>
                    <div className="absolute -top-36 -left-40 w-96 h-60 bg-emerald-800/80 rounded-full  mix-blend-multiply filter blur-3xl"></div>
                    <div className="absolute top-0 -right-40 w-96 h-96 bg-green-900/30 rounded-full mix-blend-multiply filter blur-3xl"></div>
                    {/* <div className="absolute -bottom-40 left-20 w-96 h-96 bg-teal-900/30 rounded-full mix-blend-multiply filter blur-3xl">THIHISHSIH</div> */}
                </div>
            </div>

            <div className="w-[70%] z-20 h-full gap-5 flex flex-col items-center justify-start mt-5">
                <div className="w-full flex items-center justify-start gap-5">
                    <button onClick={() => navigate(-1)} title="Go back" className="self-start hover:cursor-pointer hover:opacity-60 mt-1"><ChevronLeft className="w-5 h-5" strokeWidth={3} /></button>
                    <p className="text-xl font-semibold flex items-center justify-center gap-1"><HistoryIcon className="w-5 h-5" />History</p>
                </div>

                <div className="w-full flex items-center justify-center flex-col gap-2">
                    {
                        history && history.map((item, index) => (
                            <div key={index} className="w-[80%] rounded-lg p-3 border border-gray-800 flex flex-col items-start gap-2 justify-center">
                                <p className="text-gray-200">Prompt: {item.prompt}</p>
                                <video src={item.url} controls className="w-full h-auto rounded-lg"></video>
                                <p className="text-gray-400 text-xs self-end">{timeAgo(item.timestamp)}</p>
                            </div>
                        ))
                    }
                </div>
            </div>
        </div>
    )
}
