package views.client {
	import com.tuarua.torrent.TorrentInfo;
	import com.tuarua.torrent.TorrentPieces;
	import com.tuarua.torrent.TorrentSettings;
	import com.tuarua.torrent.TorrentStatus;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	
	import utils.TextUtils;
	import utils.TimeUtils;
	import starling.display.MeshBatch;
	import starling.utils.Align;
	
	public class InfoPanel extends Sprite {
		private var lblHolder:Sprite = new Sprite();
		private var txtHolder:Sprite = new Sprite();
		private var pieceBG:Quad = new Quad(1000,8,0x090909);
		private var pieceQB:MeshBatch = new MeshBatch();
		private var piecePartialQB:MeshBatch = new MeshBatch();
		private var numLastKnownPieces:int = 0;
		private var numPieces:int = 0;
		private var pieceLength:int = 0;
		public function InfoPanel() {
			super();
			var lblArr:Array = new Array("Progress:","Time Active:", "Downloaded:", "Download Speed:", "Download Limit:", "Share Ratio:","Total Size:","Added On:","Torrent Hash:","Save Path:","Comment:","ETA:","Uploaded:","Upload Speed:","Upload Limit:","Reannounce In:","Pieces:","Completed On:","Connections:","Seeds:","Peers:","Wasted:","Last Seen:","Created By:","Created On:");
			var lbl:TextField;
			var txt:TextField;
			txtHolder.y = lblHolder.y = 20;
			for (var i:int=0, l:int=lblArr.length; i<l; ++i){
				lbl = new TextField(120,32,lblArr[i]);
				lbl.format.setTo("Fira Sans Semi-Bold 13",13,0xD8D8D8,Align.RIGHT);
				
				txt = new TextField(1000,32,"");
				txt.format.setTo("Fira Sans Semi-Bold 13",13,0xD8D8D8,Align.LEFT);
				txt.autoSize = TextFieldAutoSize.HORIZONTAL;
				
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
			piecePartialQB.x = pieceQB.x = pieceBG.x = 140;
			piecePartialQB.y = pieceQB.y = pieceBG.y = 31;
			
			addChild(lblHolder);
			addChild(txtHolder);
			
			addChild(pieceBG);
			addChild(piecePartialQB);
			addChild(pieceQB);
			
		}
		
		public function init(_tm:TorrentInfo):void {
			if(_tm){
				numPieces = _tm.numPieces;
				pieceLength = _tm.pieceLength;
				piecePartialQB.scaleX = pieceQB.scaleX = 1000/_tm.numPieces;
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
				(txtHolder.getChildAt(11) as TextField).text = (_ts.ETA > 0 && _ts.ETA < (60*60*24*2)) ? TimeUtils.secsToTimeCode(_ts.ETA) : "";
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
			pieceQB.clear()
			piecePartialQB.clear();
			var q:Quad;
			if(_tp && _tp.pieces && _tp.pieces.length > 0){
				(txtHolder.getChildAt(16) as TextField).text = numPieces.toString() + " x " + TextUtils.bytesToString(pieceLength) + " (have "+numPieces+")";
				q = new Quad(_tp.pieces.length,8,0x4DD2FF);
				pieceQB.addMesh(q);
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
			
			pieceQB.clear();
			piecePartialQB.clear();
		}
		
		public function updatePartialPieces(p:Array):void {
			piecePartialQB.clear();
			if(p != null){
				var q:Quad;
				for (var ii:int=0, ll:int=p.length; ii<ll; ++ii){
					q = new Quad(1,8,0x3AA600);
					q.x = p[ii];
					piecePartialQB.addMesh(q);
				}
			}
		}
		
		public function updatePieces(_tp:TorrentPieces):void {
			if(_tp == null){
				pieceQB.clear();
			}else if(_tp && _tp.numDownloaded > numLastKnownPieces){
				(txtHolder.getChildAt(16) as TextField).text = numPieces.toString() + " x " + TextUtils.bytesToString(pieceLength) + " (have "+_tp.numDownloaded+")";
				pieceQB.clear();
				var q:Quad;
				for (var i:int=0, l:int=_tp.pieces.length; i<l; ++i){
					if(_tp.pieces[i] == 0)
						continue;
					q = new Quad(1,8,0x0186B3);
					q.x = i;
					pieceQB.addMesh(q);
				}
			}
		}
		
		
	}
}