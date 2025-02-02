import { ChevronLeft } from 'lucide-react'
import HeaderHome from '../home/header/HeaderHome'
import { useNavigate } from 'react-router-dom'
// import { useRef, useState } from 'react'

export default function Canvas() {
    // const canvasRef = useRef<HTMLCanvasElement | null>(null)
    // const contextRef = useRef<CanvasRenderingContext2D | null>(null)
    // const [isDrawing, setIsDrawing] = useState(false);
    // const [eraserCoords, setEraserCoords] = useState({ x: null, y: null })

    // const prepareCanvas = () => {
    //     const canvas = canvasRef.current
    //     if (!canvas) return
    //     canvas.width = window.innerWidth * 0.6;
    //     canvas.height = 400;
    
    //     const context = canvas.getContext("2d")
    //     if (!context) return
    //     context.lineCap = "round";
    //     context.lineWidth = lineWidth;
    //     context.strokeStyle = color;
    //     contextRef.current = context;
    //     // context.fillStyle = "#f9f0f0";
    //     context.fillStyle = '#333333'
    //     context.fillRect(0, 0, canvas.width, canvas.height);
    // }

    const navigate = useNavigate()
    return (
        <div className="w-[60%] h-full flex flex-col items-center justify-start">
            <HeaderHome />
            <div className="w-[70%] h-full gap-5 flex flex-col items-center justify-start mt-5">
                <div className="w-full flex items-center justify-start gap-2">
                    <button onClick={() => navigate(-1)} title="Go back" className="self-start hover:cursor-pointer hover:opacity-60 mt-1"><ChevronLeft className="w-5 h-5" strokeWidth={3} /></button>
                    <p className="text-xl font-semibold">Generate Images from your drawing</p>
                </div>
            </div>
        </div>
    )
}
