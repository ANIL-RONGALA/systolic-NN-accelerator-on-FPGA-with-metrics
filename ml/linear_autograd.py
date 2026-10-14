"""Week 1 tensor/autograd training exercise; only CPU required."""
import numpy as np
import torch

def main():
    torch.manual_seed(7)
    x = torch.arange(0,6,dtype=torch.float32).reshape(-1,1)
    y = 3*x + 2
    w = torch.nn.Parameter(torch.tensor([0.0]))
    b = torch.nn.Parameter(torch.tensor([0.0]))
    optimizer = torch.optim.SGD([w,b],lr=0.02)
    for epoch in range(600):
        optimizer.zero_grad()
        pred = w*x+b
        loss = ((pred-y)**2).mean()
        loss.backward()
        optimizer.step()
    print(f'torch={torch.__version__} w={w.item():.6f} b={b.item():.6f} loss={loss.item():.8f}')
    assert abs(w.item()-3)<0.02 and abs(b.item()-2)<0.05
    np.testing.assert_allclose((w.detach()*x+b.detach()).numpy(),w.item()*x.numpy()+b.item(),rtol=1e-5,atol=1e-5)
    print('PASS: PyTorch tensor/autograd SGD regression and NumPy comparison')
if __name__=='__main__': main()
