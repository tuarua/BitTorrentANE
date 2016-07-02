package views.client {
	import com.tuarua.torrent.TorrentMeta;
	import com.tuarua.torrent.TorrentPieces;
	import com.tuarua.torrent.TorrentSettings;
	import com.tuarua.torrent.TorrentStatus;
	
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	
	import utils.TextUtils;
	import utils.TimeUtils;
	
	public class InfoPanel extends Sprite {
		private var lblHolder:Sprite = new Sprite();
		private var txtHolder:Sprite = new Sprite();
		private var pieceBG:Quad = new Quad(1000,8,0x090909);
		private var pieceQB:QuadBatch = new QuadBatch();
		private var pieceParitalQB:QuadBatch = new QuadBatch();
		private var numLastKnownPieces:int = 0;
		private var pieceFactor:int = 1;
		private var numPieces:int = 0;
		private var pieceLength:int = 0;
		public function InfoPanel() {
			super();
			var lblArr:Array = new Array("Progress:","Time Active:", "Downloaded:", "Download Speed:", "Download Limit:", "Share Ratio:","Total Size:","Added On:","Torrent Hash:","Save Path:","Comment:","ETA:","Uploaded:","Upload Speed:","Upload Limit:","Reannounce In:","Pieces:","Completed On:","Connections:","Seeds:","Peers:","Wasted:","Last Seen:","Created By:","Created On:");
			var lbl:TextField;
			var txt:TextField;
			txtHolder.y = lblHolder.y = 20;
			for (var i:int=0, l:int=lblArr.length; i<l; ++i){
				lbl = new TextField(120,32,lblArr[i], "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
				txt = new TextField(1000,32,"", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
				txt.hAlign = HAlign.LEFT;
				txt.autoSize = TextFieldAutoSize.HORIZONTAL;
				lbl.hAlign = HAlign.RIGHT;
				txt.x = lbl.x = 0;
				if(i == 0){
					
				}else if( i < 6)
					txt.y = lbl.y = (i * 20) + 20;
				else if(i < 11)
					txt.y = lbl.y = (i * 20) + 40;
				else if(i < 16)
					txt.y = lbl.y = ((i-10) * 20) + 20;
				else if(i < 18)
					txt.y = lbl.y = ((i-10) * 20) + 40;
				else if(i < 23)
					txt.y = lbl.y = ((i-17) * 20) + 20;
				else
					txt.y = lbl.y = ((i-17) * 20) + 40;
				
				if(i < 11)
					txt.x = lbl.x = 0;
				else if(i < 18)
					txt.x = lbl.x = 400;
				else
					txt.x = lbl.x = 800;
				
				
				txt.batchable = lbl.batchable = true;
				txt.touchable = lbl.touchable = false;
				lblHolder.addChild(lbl);
				txtHolder.addChild(txt);
			}
			txtHolder.x = 130;
			pieceParitalQB.x = pieceQB.x = pieceBG.x = 140;
			pieceParitalQB.y = pieceQB.y = pieceBG.y = 31;
			pieceParitalQB.alpha = pieceQB.alpha = 0.5;
			
			addChild(lblHolder);
			addChild(txtHolder);
			
			addChild(pieceBG);
			addChild(pieceQB);
			addChild(pieceParitalQB);
		}
		
		public function init(_tm:TorrentMeta):void {
			if(_tm){
				numPieces = _tm.numPieces;
				pieceLength = _tm.pieceLength;
				pieceFactor = Math.ceil(numPieces/1000);
				pieceBG.scaleX = _tm.numPieces/(1000*pieceFactor);
				
				(txtHolder.getChildAt(6) as TextField).text = TextUtils.bytesToString(_tm.size);
				(txtHolder.getChildAt(8) as TextField).text = _tm.infoHash;
				(txtHolder.getChildAt(10) as TextField).text = _tm.comment;
				(txtHolder.getChildAt(16) as TextField).text = numPieces.toString() + " x " + TextUtils.bytesToString(pieceLength) + "(have 0)";
				(txtHolder.getChildAt(23) as TextField).text = _tm.creator;
				(txtHolder.getChildAt(24) as TextField).text = TimeUtils.unixToDate(_tm.creationDate);
			}
		}
		
		public function updateStatus(_ts:TorrentStatus):void {
			if(_ts){
				(txtHolder.getChildAt(1) as TextField).text = TimeUtils.secsToFriendly(_ts.activeTime);
				(txtHolder.getChildAt(2) as TextField).text = TextUtils.bytesToString(_ts.downloaded) + " (" + TextUtils.bytesToString(_ts.downloadedSession)+" session)";
				(txtHolder.getChildAt(3) as TextField).text = TextUtils.bytesToString(_ts.downloadRate) + "/s (" + TextUtils.bytesToString(_ts.downloadRateAverage)+"/s avg)";
				(txtHolder.getChildAt(4) as TextField).text = (_ts.downloadMax > -1) ? TextUtils.bytesToString(_ts.downloadMax) : "∞";
				(txtHolder.getChildAt(5) as TextField).text = _ts.shareRatio.toFixed(2);
				(txtHolder.getChildAt(7) as TextField).text = TimeUtils.unixToDate(_ts.addedOn);
				(txtHolder.getChildAt(9) as TextField).text = _ts.savePath;
				(txtHolder.getChildAt(11) as TextField).text = (_ts.ETA > 0) ? TimeUtils.secsToTimeCode(_ts.ETA) : "";
				(txtHolder.getChildAt(12) as TextField).text = TextUtils.bytesToString(_ts.uploaded) + " (" + TextUtils.bytesToString(_ts.uploadedSession)+" session)";
				(txtHolder.getChildAt(13) as TextField).text = TextUtils.bytesToString(_ts.uploadRate) + "/s (" + TextUtils.bytesToString(_ts.uploadRateAverage)+"/s avg)";
				(txtHolder.getChildAt(14) as TextField).text = (_ts.uploadMax > -1) ? TextUtils.bytesToString(_ts.uploadMax) : "∞";
				(txtHolder.getChildAt(15) as TextField).text = (_ts.nextAnnounce > 0) ? TimeUtils.secsToTimeCode(_ts.nextAnnounce) : "";
				(txtHolder.getChildAt(17) as TextField).text = (_ts.completedOn > 0) ? TimeUtils.unixToDate(_ts.completedOn) : "";
				(txtHolder.getChildAt(18) as TextField).text = _ts.numConnections.toString() + " ("+TorrentSettings.connections.maxNum.toString()+" max)";
				
				(txtHolder.getChildAt(19) as TextField).text = _ts.numSeeds.toString() + " ("+_ts.numSeedsTotal.toString()+" max)";
				(txtHolder.getChildAt(20) as TextField).text = _ts.numPeers.toString() + " ("+_ts.numPeersTotal.toString()+" max)";
				(txtHolder.getChildAt(21) as TextField).text = TextUtils.bytesToString(_ts.wasted);
				(txtHolder.getChildAt(22) as TextField).text = (_ts.lastSeenComplete > 0) ? TimeUtils.unixToDate(_ts.lastSeenComplete) : "";
			}
			
		}
		
		public function finishPieces(_tp:TorrentPieces):void {
			pieceQB.reset();
			pieceParitalQB.reset();
			var q:Quad;
			if(_tp && _tp.pieces && _tp.pieces.length > 0){
				(txtHolder.getChildAt(16) as TextField).text = numPieces.toString() + " x " + TextUtils.bytesToString(pieceLength) + " (have "+numPieces+")";
				q = new Quad(Math.ceil(_tp.pieces.length/pieceFactor),8,0x4DD2FF);
				pieceQB.addQuad(q);
			}
		}
		
		public function clear():void {
			(txtHolder.getChildAt(6) as TextField).text = "";
			(txtHolder.getChildAt(8) as TextField).text = "";
			(txtHolder.getChildAt(10) as TextField).text = "";
			(txtHolder.getChildAt(16) as TextField).text = "";
			(txtHolder.getChildAt(23) as TextField).text = "";
			(txtHolder.getChildAt(24) as TextField).text = "";
			
			(txtHolder.getChildAt(1) as TextField).text = "";
			(txtHolder.getChildAt(2) as TextField).text = "";
			(txtHolder.getChildAt(3) as TextField).text = "";
			(txtHolder.getChildAt(4) as TextField).text = "";
			(txtHolder.getChildAt(5) as TextField).text = "";
			(txtHolder.getChildAt(7) as TextField).text = "";
			(txtHolder.getChildAt(9) as TextField).text = "";
			(txtHolder.getChildAt(11) as TextField).text = "";
			(txtHolder.getChildAt(12) as TextField).text = "";
			(txtHolder.getChildAt(13) as TextField).text = "";
			(txtHolder.getChildAt(14) as TextField).text = "";
			(txtHolder.getChildAt(15) as TextField).text = "";
			(txtHolder.getChildAt(17) as TextField).text = "";
			(txtHolder.getChildAt(18) as TextField).text = "";
			
			(txtHolder.getChildAt(19) as TextField).text = "";
			(txtHolder.getChildAt(20) as TextField).text = "";
			(txtHolder.getChildAt(21) as TextField).text = "";
			(txtHolder.getChildAt(22) as TextField).text = "";
			
			pieceQB.reset();
			pieceParitalQB.reset();
		}
		
		public function updatePartialPieces(p:Vector.<int>):void {
			
			pieceParitalQB.reset();
			if(p != null){
				var finalArr:Vector.<int> = new Vector.<int>();
				var val:int;
				for (var i:int=0, l:int=p.length; i<l; ++i){
					val = Math.floor(p[i]/pieceFactor);
					if(finalArr.lastIndexOf(val) == -1)
						finalArr.push(val);
				}
				var q:Quad;
				for (var ii:int=0, ll:int=finalArr.length; ii<ll; ++ii){
					q = new Quad(1,8,0x6DD900);
					q.x = finalArr[ii];
					pieceParitalQB.addQuad(q);
				}
			}
		}
		
		public function updatePieces(_tp:TorrentPieces):void {
			//only render if I need to
			//handle > 1000
			
			if(_tp == null){
				pieceQB.reset();
			}else if(_tp && _tp.numDownloaded > numLastKnownPieces){
				(txtHolder.getChildAt(16) as TextField).text = numPieces.toString() + " x " + TextUtils.bytesToString(pieceLength) + " (have "+_tp.numDownloaded+")";
				pieceQB.reset();
				var fnlArr:Array = new Array();
				var startIndex:int = 0;
				var endIndex:int = 0;
				
				while(startIndex > -1 && endIndex > -1){
					startIndex = _tp.pieces.indexOf(1,endIndex);
					if(startIndex == -1) break;
					endIndex = _tp.pieces.indexOf(0,startIndex);
					if(endIndex == -1) {
						fnlArr.push(new Array(_tp.pieces.length-1,1));
						break;
					}
					fnlArr.push(new Array(startIndex,(endIndex-startIndex)));
				}
				
				if(pieceFactor > 1){
					var fnlArr2:Array = new Array();
					var from:int;
					var to:int;
					for (var ii:int=0, ll:int=fnlArr.length; ii<ll; ++ii){
						
						if(fnlArr[ii][1] < pieceFactor)
							continue;
						
						if(fnlArr[ii][0] == 0)
							from = 0
						else
							from = Math.floor(fnlArr[ii][0]/pieceFactor);
						to =  Math.floor(fnlArr[ii][1]/pieceFactor)
						fnlArr2.push(new Array(from,to));
					}
					fnlArr = fnlArr2;
				}
				
				var q:Quad;
				for (var i:int=0, l:int=fnlArr.length; i<l; ++i){
					q = new Quad(fnlArr[i][1],8,0x4DD2FF);
					q.x = fnlArr[i][0];
					pieceQB.addQuad(q);
				}
			}
			
			
		}
		
	}
}